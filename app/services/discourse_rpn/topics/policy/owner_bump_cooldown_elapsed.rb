# frozen_string_literal: true

module ::DiscourseRpn
  module Topics
    module Policy
      class OwnerBumpCooldownElapsed < Service::PolicyBase
        delegate :topic, to: :context, private: true

        def call
          topic.owner_bump_available?
        end

        def reason
          remaining = topic.owner_bump_available_at - Time.zone.now

          # Below two days, rounding to whole days would hide too many hours.
          if remaining >= 2.days
            I18n.t("discourse_rpn.topic_owner_bump.cooldown_days", count: (remaining / 1.day).round)
          elsif remaining >= 1.hour
            I18n.t(
              "discourse_rpn.topic_owner_bump.cooldown_hours",
              count: (remaining / 1.hour).ceil,
            )
          else
            I18n.t(
              "discourse_rpn.topic_owner_bump.cooldown_minutes",
              count: (remaining / 1.minute).ceil,
            )
          end
        end
      end
    end
  end
end
