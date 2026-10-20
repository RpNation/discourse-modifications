# frozen_string_literal: true

module ::DiscourseRpn
  module SlugAsciiPatch
    def ascii_generator(string)
      super(AnyAscii.transliterate(string.to_s))
    end
  end
end
