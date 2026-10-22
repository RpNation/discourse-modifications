# frozen_string_literal: true

RSpec.describe DiscourseRpn::ForcedCategoryWatching do
  fab!(:user)
  fab!(:category)

  let(:levels) { CategoryUser.notification_levels }

  def level_for(user, category)
    CategoryUser.find_by(user:, category:)&.notification_level
  end

  def insert_level(level)
    CategoryUser.insert_all!(
      [{ user_id: user.id, category_id: category.id, notification_level: levels[level] }],
    )
  end

  before do
    SiteSetting.discourse_rpn_enabled = true
    SiteSetting.locked_min_watch_categories = category.id.to_s
  end

  describe ".enforce" do
    it "creates a watching first post row when the user has none" do
      described_class.enforce(user)

      expect(level_for(user, category)).to eq(levels[:watching_first_post])
    end

    it "raises a lower level to watching first post" do
      insert_level(:muted)

      described_class.enforce(user)

      expect(level_for(user, category)).to eq(levels[:watching_first_post])
    end

    it "leaves watching alone" do
      insert_level(:watching)

      described_class.enforce(user)

      expect(level_for(user, category)).to eq(levels[:watching])
    end

    it "skips staged users" do
      staged = Fabricate(:user, staged: true)

      described_class.enforce(staged)

      expect(level_for(staged, category)).to be_nil
    end

    it "does nothing when the plugin is disabled" do
      SiteSetting.discourse_rpn_enabled = false

      described_class.enforce(user)

      expect(level_for(user, category)).to be_nil
    end
  end

  describe "CategoryUser" do
    before { described_class.enforce(user) }

    it "refuses to destroy the row" do
      row = CategoryUser.find_by(user:, category:)

      expect { row.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      expect(CategoryUser.find_by(user:, category:)).to eq(row)
    end

    it "skips the row when destroyed in bulk, as the unsubscribe link does" do
      row = CategoryUser.find_by(user:, category:)

      CategoryUser.where(user:, category:).destroy_all

      expect(CategoryUser.find_by(user:, category:)).to eq(row)
    end

    it "keeps the floor when a batch update leaves the category out" do
      CategoryUser.batch_set(user, :watching_first_post, [])

      expect(level_for(user, category)).to eq(levels[:watching_first_post])
    end

    it "keeps the floor when a batch update moves the category to muted" do
      CategoryUser.batch_set(user, :muted, [category.id])

      expect(level_for(user, category)).to eq(levels[:watching_first_post])
    end

    it "lets the user raise their level to watching" do
      CategoryUser.set_notification_level_for_category(user, levels[:watching], category.id)

      expect(level_for(user, category)).to eq(levels[:watching])
    end

    it "does not recreate the row when the user is destroyed" do
      expect { UserDestroyer.new(Discourse.system_user).destroy(user) }.not_to raise_error

      expect(CategoryUser.where(user_id: user.id)).to be_empty
    end
  end

  context "when the plugin is disabled" do
    before do
      described_class.enforce(user)
      SiteSetting.discourse_rpn_enabled = false
    end

    it "lets the row be destroyed" do
      CategoryUser.find_by(user:, category:).destroy!

      expect(level_for(user, category)).to be_nil
    end

    it "lets the level be lowered" do
      CategoryUser.set_notification_level_for_category(user, levels[:muted], category.id)

      expect(level_for(user, category)).to eq(levels[:muted])
    end

    it "lets a batch update change the level" do
      CategoryUser.batch_set(user, :muted, [category.id])

      expect(level_for(user, category)).to eq(levels[:muted])
    end

    it "does not give new users the floor" do
      expect(level_for(Fabricate(:user), category)).to be_nil
    end
  end

  it "gives new users the floor" do
    new_user = Fabricate(:user)

    expect(level_for(new_user, category)).to eq(levels[:watching_first_post])
  end
end
