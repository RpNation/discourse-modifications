import { withPluginApi } from "discourse/lib/plugin-api";
import EditTopicTagsButton from "../components/edit-topic-tags-button";
import TagListIcon from "../components/tag-list-icon";

const TAG_WRAPPER_OUTLETS = [
  "bookmark-list-tags-wrapper",
  "header-tags-wrapper",
  "latest-topic-list-item-tags-wrapper",
  "reviewable-tags-wrapper",
  "search-menu-results-topic-tags-wrapper",
  "search-result-entry-tags-wrapper",
  "timeline-tags-wrapper",
  "topic-category-tags-wrapper",
  "topic-list-tags-wrapper",
];

export default {
  name: "tag-list-icon",

  initialize() {
    withPluginApi((api) => {
      if (
        !api.container.lookup("service:site-settings").discourse_rpn_enabled
      ) {
        return;
      }

      TAG_WRAPPER_OUTLETS.forEach((outlet) =>
        api.renderBeforeWrapperOutlet(outlet, TagListIcon)
      );

      api.renderAfterWrapperOutlet(
        "topic-category-tags-wrapper",
        EditTopicTagsButton
      );
    });
  },
};
