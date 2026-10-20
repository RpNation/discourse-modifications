# frozen_string_literal: true

module PageObjects
  module Components
    class TopicOwnerBumpNotice < PageObjects::Components::Base
      def has_bump_by?(user)
        has_css?(
          ".small-action[data-user-id='#{user.id}'] .small-action-contents",
          text: I18n.t("js.action_codes.owner_bumped", when: I18n.t("js.now")),
        )
      end
    end
  end
end
