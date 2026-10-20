# frozen_string_literal: true

RSpec.describe DiscourseRpn::TopicExtension do
  fab!(:owner) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:topic) { create_post(user: owner, created_at: 2.days.ago).topic }

  before { freeze_time }

  describe "#owner_bump_available_at" do
    it "is the cooldown after the topic was last bumped" do
      expect(topic.owner_bump_available_at).to eq_time(topic.bumped_at + 24.hours)
    end

    it "follows the cooldown setting" do
      SiteSetting.topic_owner_bump_cooldown_minutes = 90

      expect(topic.owner_bump_available_at).to eq_time(topic.bumped_at + 90.minutes)
    end

    it "restarts the cooldown when someone replies" do
      create_post(topic:)

      expect(topic.reload.owner_bump_available_at).to eq_time(24.hours.from_now)
    end

    it "keeps the cooldown of the latest owner bump after a later reply is deleted" do
      bump_post =
        topic.add_small_action(owner, DiscourseRpn::TOPIC_OWNER_BUMP_ACTION_CODE, nil, bump: true)
      reply = create_post(user: owner, topic:)
      PostDestroyer.new(owner, reply).destroy

      expect(topic.reload.owner_bump_available_at).to eq_time(bump_post.created_at + 24.hours)
    end

    it "keeps the cooldown of a deleted owner bump after a later reply is deleted" do
      bump_post =
        topic.add_small_action(owner, DiscourseRpn::TOPIC_OWNER_BUMP_ACTION_CODE, nil, bump: true)
      PostDestroyer.new(Fabricate(:admin), bump_post).destroy
      reply = create_post(user: owner, topic:)
      PostDestroyer.new(owner, reply).destroy

      expect(topic.reload.owner_bump_available_at).to eq_time(bump_post.created_at + 24.hours)
    end
  end

  describe "#owner_bump_available?" do
    it "returns true once the cooldown has elapsed" do
      expect(topic.owner_bump_available?).to eq(true)
    end

    it "returns true at the exact moment the cooldown ends" do
      topic.update!(bumped_at: 24.hours.ago)

      expect(topic.owner_bump_available?).to eq(true)
    end

    it "returns false during the cooldown" do
      topic.update!(bumped_at: 1.hour.ago)

      expect(topic.owner_bump_available?).to eq(false)
    end
  end
end
