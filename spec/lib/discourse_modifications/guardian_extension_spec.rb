# frozen_string_literal: true

RSpec.describe DiscourseModifications::GuardianExtension do
  fab!(:owner) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category, :topic_owner_bump_category)
  fab!(:topic) { Fabricate(:topic, user: owner, category:) }

  before { enable_current_plugin }

  describe "#can_bump_topic?" do
    it "returns true for the topic owner" do
      expect(owner.guardian.can_bump_topic?(topic)).to eq(true)
    end

    it "returns false when the plugin is disabled" do
      SiteSetting.discourse_modifications_enabled = false

      expect(owner.guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false for another user" do
      other_user = Fabricate(:user, refresh_auto_groups: true)

      expect(other_user.guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false for an admin who does not own the topic" do
      expect(Fabricate(:admin).guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false for anonymous users" do
      expect(Guardian.new.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false for a private message" do
      private_message = Fabricate(:private_message_topic, user: owner)

      expect(owner.guardian.can_bump_topic?(private_message)).to eq(false)
    end

    it "returns false when the topic is closed" do
      topic.update!(closed: true)

      expect(owner.guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false when the topic is archived" do
      topic.update!(archived: true)

      expect(owner.guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false when the topic is unlisted" do
      topic.update!(visible: false)

      expect(owner.guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false when the topic is deleted" do
      topic.trash!

      expect(owner.guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false when the category has not opted in" do
      topic.update!(category: Fabricate(:category))

      expect(owner.guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false when the owner can only read the category" do
      category.set_permissions(everyone: :readonly)
      category.save!

      expect(owner.guardian.can_bump_topic?(topic)).to eq(false)
    end

    it "returns false when the owner is silenced" do
      owner.update!(silenced_till: 1.year.from_now)

      expect(owner.guardian.can_bump_topic?(topic)).to eq(false)
    end
  end
end
