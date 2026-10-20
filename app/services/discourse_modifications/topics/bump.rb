# frozen_string_literal: true

module ::DiscourseModifications
  module Topics
    class Bump
      include Service::Base

      params do
        attribute :topic_id, :integer

        validates :topic_id, presence: true
      end

      # The topic is fetched inside the lock so a concurrent bump can't leave
      # us checking the cooldown against a stale `bumped_at`.
      lock(:topic_id) do
        model :topic
        policy :can_see_topic
        policy :can_bump_topic
        policy :owner_bump_cooldown_elapsed, class_name: Policy::OwnerBumpCooldownElapsed
        model :bump_post, :bump_topic
      end

      private

      def fetch_topic(params:)
        Topic.find_by(id: params.topic_id)
      end

      def can_see_topic(guardian:, topic:)
        guardian.can_see_topic?(topic)
      end

      def can_bump_topic(guardian:, topic:)
        guardian.can_bump_topic?(topic)
      end

      def bump_topic(guardian:, topic:)
        topic.add_small_action(guardian.user, TOPIC_OWNER_BUMP_ACTION_CODE, nil, bump: true)
      end
    end
  end
end
