import Component from "@glimmer/component";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import DButton from "discourse/ui-kit/d-button";

export default class EditTopicTagsButton extends Component {
  get canEdit() {
    const { topic, tags } = this.args.outletArgs;
    return topic?.details?.can_edit && tags?.length > 0;
  }

  @action
  edit(event) {
    getOwner(this).lookup("controller:topic").editTopic(event);
  }

  <template>
    {{#if this.canEdit}}
      <DButton
        class="btn-flat btn-icon edit-topic-tags"
        @action={{this.edit}}
        @icon="pencil"
        @title="edit_topic"
      />
    {{/if}}
  </template>
}
