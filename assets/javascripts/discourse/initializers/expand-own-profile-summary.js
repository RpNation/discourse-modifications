import { computed } from "@ember/object";
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "expand-own-profile-summary",

  initialize() {
    withPluginApi((api) => {
      if (
        !api.container.lookup("service:site-settings").discourse_rpn_enabled
      ) {
        return;
      }

      api.modifyClass(
        "controller:user",
        (Superclass) =>
          class extends Superclass {
            // On your own summary the panel starts expanded, so the toggle
            // (which flips `forceExpand`) collapses it instead of expanding.
            @computed(
              "model.profile_hidden",
              "isSummaryRoute",
              "viewingSelf",
              "forceExpand"
            )
            get collapsedInfo() {
              if (
                this.viewingSelf &&
                this.isSummaryRoute &&
                !this.model?.profile_hidden
              ) {
                return !!this.forceExpand;
              }
              return super.collapsedInfo;
            }
          }
      );
    });
  },
};
