# frozen_string_literal: true

Fabricator(:topic_owner_bump_category, from: :category) do
  custom_fields { { DiscourseModifications::TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD => true } }
end
