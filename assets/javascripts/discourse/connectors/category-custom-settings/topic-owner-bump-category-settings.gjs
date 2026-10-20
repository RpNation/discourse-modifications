import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";

export default class TopicOwnerBumpCategorySettings extends Component {
  static shouldRender(args, context) {
    return context.siteSettings.discourse_modifications_enabled;
  }

  <template>
    <@outletArgs.form.Section
      class="category-custom-settings-outlet topic-owner-bump-category-settings"
      @title={{i18n
        "discourse_modifications.topic_owner_bump.category_settings_heading"
      }}
    >
      <@outletArgs.form.Object @name="custom_fields" as |object|>
        <object.Field
          @description={{i18n
            "discourse_modifications.topic_owner_bump.category_setting_description"
          }}
          @format="max"
          @name="topic_owner_bump_enabled"
          @title={{i18n
            "discourse_modifications.topic_owner_bump.category_setting"
          }}
          @type="checkbox"
          as |field|
        >
          <field.Control />
        </object.Field>
      </@outletArgs.form.Object>
    </@outletArgs.form.Section>
  </template>
}
