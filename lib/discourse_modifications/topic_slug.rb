# frozen_string_literal: true

require 'any_ascii'

module ::DiscourseModifications
  class TopicSlug
    
    # Converts a topic title into a slug, removing any emoji strings and normalizing the text.
    # This is primarily adds the unicode normalization step to the existing slug generation process
    # for ASCII encoding.
    def self.slug_for_topic(topic, slug, title)
      return slug unless (SiteSetting.slug_generation_method || :ascii).to_sym == :ascii

      string = title.gsub(/:([\w\-+]+(?::t\d)?):/, "")
      string = AnyAscii.transliterate(string)
      string = Slug.ascii_generator(string)
      string = Slug.prettify_slug(string, max_length: Slug::MAX_LENGTH)

      string.blank? || Slug.slug_is_only_numbers?(string) ? "topic-#{topic.id}" : string
    end
  end
end