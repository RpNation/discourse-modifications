import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Discourse RPN | Own profile summary", function (needs) {
  needs.user();
  needs.settings({ discourse_rpn_enabled: true });

  const collapsed = `button[aria-controls="collapsed-info-panel"][aria-expanded="false"]`;
  const expanded = `button[aria-controls="collapsed-info-panel"][aria-expanded="true"]`;

  test("info panel starts expanded and can be collapsed", async function (assert) {
    await visit("/u/eviltrout/summary");
    assert.dom(expanded).exists("info panel is expanded by default");

    await click(expanded);
    assert.dom(collapsed).exists("info panel is collapsed");

    await click(collapsed);
    assert.dom(expanded).exists("info panel is expanded again");
  });

  test("info panel starts collapsed on other tabs", async function (assert) {
    await visit("/u/eviltrout/activity");
    assert.dom(collapsed).exists("info panel is collapsed");
  });
});
