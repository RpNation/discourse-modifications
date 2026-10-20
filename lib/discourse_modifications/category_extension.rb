# frozen_string_literal: true

module ::DiscourseModifications
  module CategoryExtension
    def topic_owner_bump_enabled?
      custom_fields[TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD] == true ||
        !!parent_category&.topic_owner_bump_enabled?
    end
  end
end
