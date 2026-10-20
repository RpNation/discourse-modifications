import { trackedObject } from "@ember/reactive/collections";
import { render, settled } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { fakeTime } from "discourse/tests/helpers/qunit-helpers";
import TopicOwnerBumpButton from "discourse/plugins/discourse-rpn/discourse/connectors/topic-footer-main-buttons-before-create/topic-owner-bump-button";

const NOW = "2026-10-20T12:00:00Z";

function outletArgsAvailableAt(availableAt) {
  return { topic: { id: 1, owner_bump_available_at: availableAt } };
}

module("Integration | Component | TopicOwnerBumpButton", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.clock = fakeTime(NOW);
  });

  hooks.afterEach(function () {
    this.clock.restore();
  });

  test("is enabled with a plain label once the cooldown is over", async function (assert) {
    const outletArgs = outletArgsAvailableAt("2026-10-20T11:00:00Z");

    await render(
      <template><TopicOwnerBumpButton @outletArgs={{outletArgs}} /></template>
    );

    assert.dom(".topic-owner-bump").isEnabled().hasText("Bump");
  });

  test("counts down and re-enables when the cooldown ends", async function (assert) {
    const outletArgs = outletArgsAvailableAt("2026-10-20T12:01:05Z");

    await render(
      <template><TopicOwnerBumpButton @outletArgs={{outletArgs}} /></template>
    );

    assert.dom(".topic-owner-bump").isDisabled().hasText("Bump in 2m");

    this.clock.tick(6000);
    await settled();

    assert.dom(".topic-owner-bump").hasText("Bump in 1m");

    this.clock.tick(59000);
    await settled();

    assert.dom(".topic-owner-bump").isEnabled().hasText("Bump");
  });

  test("rounds days down, hours to the nearest hour and minutes up", async function (assert) {
    const cases = [
      ["2026-10-22T23:59:00Z", "Bump in 2d"],
      ["2026-10-21T12:00:00Z", "Bump in 1d"],
      ["2026-10-20T15:29:00Z", "Bump in 3h"],
      ["2026-10-20T15:31:00Z", "Bump in 4h"],
      ["2026-10-20T13:00:00Z", "Bump in 1h"],
      ["2026-10-20T12:59:59Z", "Bump in 60m"],
      ["2026-10-20T12:00:01Z", "Bump in 1m"],
    ];

    for (const [availableAt, expectedLabel] of cases) {
      const outletArgs = outletArgsAvailableAt(availableAt);

      await render(
        <template><TopicOwnerBumpButton @outletArgs={{outletArgs}} /></template>
      );

      assert
        .dom(".topic-owner-bump")
        .hasText(expectedLabel, `available at ${availableAt}`);
    }
  });

  test("restarts the countdown when the available time changes and stops it when it ends", async function (assert) {
    const topic = trackedObject({
      id: 1,
      owner_bump_available_at: "2026-10-20T11:00:00Z",
    });
    const outletArgs = { topic };

    await render(
      <template><TopicOwnerBumpButton @outletArgs={{outletArgs}} /></template>
    );

    assert.dom(".topic-owner-bump").isEnabled().hasText("Bump");
    assert.strictEqual(this.clock.countTimers(), 0, "no timer while enabled");

    topic.owner_bump_available_at = "2026-10-20T12:01:05Z";
    await settled();

    assert.dom(".topic-owner-bump").isDisabled().hasText("Bump in 2m");
    assert.strictEqual(this.clock.countTimers(), 1, "timer restarted");

    this.clock.tick(65000);
    await settled();

    assert.dom(".topic-owner-bump").isEnabled().hasText("Bump");
    assert.strictEqual(this.clock.countTimers(), 0, "timer torn down");
  });
});
