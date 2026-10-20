import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "topic-owner-bump",

  initialize() {
    withPluginApi((api) => {
      api.addTrackedTopicProperties("owner_bump_available_at");
      api.addPostSmallActionIcon("owner_bumped", "hand-point-right");

      api.registerCustomPostMessageCallback(
        "owner_bump_available_at",
        (topicController, data) => {
          const topic = topicController.model;

          // Only owners who can bump have the field; don't add it for anyone else.
          if (topic?.owner_bump_available_at) {
            topic.owner_bump_available_at = data.owner_bump_available_at;
          }
        }
      );
    });
  },
};
