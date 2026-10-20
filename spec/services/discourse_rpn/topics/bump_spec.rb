# frozen_string_literal: true

RSpec.describe DiscourseRpn::Topics::Bump do
  describe described_class::Contract, type: :model do
    it { is_expected.to validate_presence_of(:topic_id) }
  end

  describe ".call" do
    subject(:result) { described_class.call(params:, **dependencies) }

    fab!(:owner) { Fabricate(:user, refresh_auto_groups: true) }
    fab!(:acting_user) { owner }
    fab!(:category, :topic_owner_bump_category)
    fab!(:topic) { create_post(user: owner, category:, created_at: 2.days.ago).topic }

    let(:params) { { topic_id: } }
    let(:dependencies) { { guardian: acting_user.guardian } }
    let(:topic_id) { topic.id }

    before { enable_current_plugin }

    context "when contract is invalid" do
      let(:topic_id) { nil }

      it { is_expected.to fail_a_contract }
    end

    context "when topic is not found" do
      let(:topic_id) { 0 }

      it { is_expected.to fail_to_find_a_model(:topic) }
    end

    context "when the user cannot see the topic" do
      before do
        category.set_permissions(staff: :full)
        category.save!
      end

      it { is_expected.to fail_a_policy(:can_see_topic) }
    end

    context "when the user cannot bump the topic" do
      fab!(:acting_user) { Fabricate(:user, refresh_auto_groups: true) }

      it { is_expected.to fail_a_policy(:can_bump_topic) }
    end

    context "when the cooldown has not elapsed" do
      before { topic.update!(bumped_at: 1.hour.ago) }

      it { is_expected.to fail_a_policy(:owner_bump_cooldown_elapsed) }
    end

    context "when a deleted reply rewound the topic past the latest owner bump" do
      before do
        freeze_time(2.hours.ago) do
          topic.add_small_action(owner, DiscourseRpn::TOPIC_OWNER_BUMP_ACTION_CODE, nil, bump: true)
        end
        reply = create_post(user: owner, topic:, created_at: 1.hour.ago)
        PostDestroyer.new(owner, reply).destroy
      end

      it { is_expected.to fail_a_policy(:owner_bump_cooldown_elapsed) }
    end

    context "when everything's ok" do
      before { freeze_time }

      it { is_expected.to run_successfully }

      it "creates a bump small action post by the owner" do
        expect(result[:bump_post]).to have_attributes(
          topic:,
          user: owner,
          post_type: Post.types[:small_action],
          action_code: DiscourseRpn::TOPIC_OWNER_BUMP_ACTION_CODE,
        )
      end

      it "bumps the topic" do
        expect { result }.to change { topic.reload.bumped_at }.to(eq_time(Time.zone.now))
      end
    end
  end
end
