# frozen_string_literal: true

# name: discourse-modifications
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_modifications_enabled

module ::DiscourseModifications
  PLUGIN_NAME = "discourse-modifications"
end

require_relative "lib/discourse_modifications/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
