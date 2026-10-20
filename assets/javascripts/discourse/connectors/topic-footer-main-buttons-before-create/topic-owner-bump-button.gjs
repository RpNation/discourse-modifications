import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";

const MS_PER_SECOND = 1000;
const MINUTE = 60;
const HOUR = 60 * MINUTE;
const DAY = 24 * HOUR;

function formatTimeLeft(totalSeconds) {
  if (totalSeconds >= DAY) {
    return i18n("dates.tiny.x_days", {
      count: Math.floor(totalSeconds / DAY),
    });
  }

  if (totalSeconds >= HOUR) {
    return i18n("dates.tiny.about_x_hours", {
      count: Math.round(totalSeconds / HOUR),
    });
  }

  // Rounding up keeps the last seconds from reading "0m".
  return i18n("dates.tiny.x_minutes", {
    count: Math.ceil(totalSeconds / MINUTE),
  });
}

export default class TopicOwnerBumpButton extends Component {
  static shouldRender(args) {
    return !!args.topic?.owner_bump_available_at;
  }

  @tracked isBumping = false;
  @tracked lastTick = Date.now();

  // Re-runs whenever the available time changes (a bump or a live update) and
  // tears the previous timer down, so nothing ticks once the cooldown is over.
  countdown = modifier((element, [availableAt]) => {
    const endsAt = new Date(availableAt);

    if (endsAt <= Date.now()) {
      return;
    }

    const timer = setInterval(() => {
      this.lastTick = Date.now();

      if (endsAt <= this.lastTick) {
        clearInterval(timer);
      }
    }, MS_PER_SECOND);

    return () => clearInterval(timer);
  });

  get isCoolingDown() {
    return this.remainingSeconds > 0;
  }

  get label() {
    if (!this.isCoolingDown) {
      return i18n("discourse_rpn.topic_owner_bump.button_label");
    }

    return i18n("discourse_rpn.topic_owner_bump.button_countdown", {
      timeLeft: formatTimeLeft(this.remainingSeconds),
    });
  }

  get remainingSeconds() {
    const availableAt = new Date(this.topic.owner_bump_available_at);
    // Reading `lastTick` re-renders on each tick, but the clock is read fresh so
    // a new available time shows correctly before the first tick.
    const now = this.lastTick && Date.now();
    return Math.ceil((availableAt - now) / MS_PER_SECOND);
  }

  get topic() {
    return this.args.outletArgs.topic;
  }

  @action
  async bump() {
    this.isBumping = true;

    try {
      const result = await ajax(`/discourse-rpn/topics/${this.topic.id}/bump`, {
        type: "POST",
      });
      this.topic.owner_bump_available_at = result.owner_bump_available_at;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isBumping = false;
    }
  }

  <template>
    <DButton
      class="btn-default topic-footer-button topic-owner-bump"
      id="topic-footer-button-topic-owner-bump"
      @action={{this.bump}}
      @disabled={{this.isCoolingDown}}
      @icon="hand-point-right"
      @isLoading={{this.isBumping}}
      @title="discourse_rpn.topic_owner_bump.button_title"
      @translatedLabel={{this.label}}
      {{this.countdown this.topic.owner_bump_available_at}}
    />
  </template>
}
