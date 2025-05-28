# frozen_string_literal: true

# name: discourse-modifications
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Alteras1, Ghan
# url: TODO
# required_version: 2.7.0

gem 'any_ascii', '0.3.2'

enabled_site_setting :discourse_modifications_enabled

module ::DiscourseModifications
  PLUGIN_NAME = "discourse-modifications"
end

require_relative "lib/discourse_modifications/engine"

after_initialize do
  # Code which should run after Rails has finished booting
  
  # Note: if this file gets too large, consider moving code into separate files in the lib directory
  # and applying a Initializer pattern to load them.

  Topic.slug_computed_callbacks << ::DiscourseModifications::TopicSlug.method(:slug_for_topic)
end
