# frozen_string_literal: true

# name: discourse-modifications
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Alteras1, Ghan
# url: TODO
# required_version: 2.7.0

gem "any_ascii", "0.3.2"

enabled_site_setting :discourse_modifications_enabled

module ::DiscourseModifications
  PLUGIN_NAME = "discourse-modifications"
  TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD = "topic_owner_bump_enabled"
  TOPIC_OWNER_BUMP_ACTION_CODE = "owner_bumped"
  OWNER_BUMP_MESSAGE_TYPE = "owner_bump_available_at"
end

require_relative "lib/discourse_modifications/engine"

after_initialize do
  # Patch Slug.ascii_generator to use AnyAscii before parameterize so that
  # Unicode characters (including mathematical/stylised variants) transliterate
  # correctly everywhere Slug.for is called — AR lifecycle hooks, bulk import,
  # category slugs, etc.
  Slug.singleton_class.prepend(::DiscourseModifications::SlugAsciiPatch)

  register_category_custom_field_type(
    DiscourseModifications::TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD,
    :boolean,
  )

  reloadable_patch do
    Category.include(DiscourseModifications::CategoryExtension)
    Topic.include(DiscourseModifications::TopicExtension)
    Guardian.include(DiscourseModifications::GuardianExtension)
  end

  # New posts bump with `update_columns`, which skips the topic's commit hook.
  # Whispers never bump, and publishing for them would reveal they exist.
  on(:post_created) { |post| post.topic.publish_owner_bump_available_at if !post.whisper? }

  add_to_serializer(
    :topic_view,
    :owner_bump_available_at,
    include_condition: -> { scope.can_bump_topic?(object.topic) },
  ) { object.topic.owner_bump_available_at }
end
