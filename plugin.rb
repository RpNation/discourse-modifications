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
end

require_relative "lib/discourse_modifications/engine"

after_initialize do
  # Patch Slug.ascii_generator to use AnyAscii before parameterize so that
  # Unicode characters (including mathematical/stylised variants) transliterate
  # correctly everywhere Slug.for is called — AR lifecycle hooks, bulk import,
  # category slugs, etc.
  Slug.singleton_class.prepend(::DiscourseModifications::SlugAsciiPatch)
end
