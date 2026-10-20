# frozen_string_literal: true

module ::DiscourseRpn
  module TopicExtension
    extend ActiveSupport::Concern

    included do
      # Deleting and restoring posts rewinds `bumped_at` through a regular save.
      after_commit :publish_owner_bump_available_at, on: :update, if: :saved_change_to_bumped_at?
    end

    # Deleting a reply rewinds `bumped_at` to the last regular post, skipping
    # bump posts, so the latest bump is checked separately.
    def owner_bump_available_at
      [bumped_at, latest_owner_bump_at].compact.max +
        SiteSetting.topic_owner_bump_cooldown_minutes.minutes
    end

    def owner_bump_available?
      !owner_bump_available_at.future?
    end

    def publish_owner_bump_available_at
      return if !user&.guardian&.can_bump_topic?(self)

      MessageBus.publish(
        "/topic/#{id}",
        { type: OWNER_BUMP_MESSAGE_TYPE, owner_bump_available_at: },
        user_ids: [user_id],
      )
    end

    private

    def latest_owner_bump_at
      Post
        .with_deleted
        .where(topic_id: id, action_code: TOPIC_OWNER_BUMP_ACTION_CODE)
        .maximum(:created_at)
    end
  end
end
