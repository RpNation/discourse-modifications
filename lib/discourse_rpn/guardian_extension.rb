# frozen_string_literal: true

module ::DiscourseRpn
  module GuardianExtension
    def can_bump_topic?(topic)
      return false if !SiteSetting.discourse_rpn_enabled
      return false if !is_my_own?(topic)
      return false if topic.private_message? || topic.closed? || topic.archived? || !topic.visible?

      !!topic.category&.topic_owner_bump_enabled? && can_create_post_on_topic?(topic)
    end
  end
end
