import Component from "@glimmer/component";
import bodyClass from "discourse/helpers/body-class";

export default class LockedWatchCategoryClass extends Component {
  static shouldRender({ category }, { siteSettings }) {
    return (
      siteSettings.discourse_rpn_enabled &&
      siteSettings.locked_min_watch_categories
        .split("|")
        .includes(String(category.id))
    );
  }

  <template>{{bodyClass "rpn-locked-watch-category"}}</template>
}
