# frozen_string_literal: true

RSpec.describe DiscourseRpn::Topics::Policy::OwnerBumpCooldownElapsed do
  subject(:policy) { described_class.new(context) }

  fab!(:topic)

  let(:context) { Service::Base::Context.build(topic:) }
  let(:bumped_at) { 1.hour.ago }

  before do
    freeze_time
    topic.update!(bumped_at:)
  end

  describe "#call" do
    subject(:result) { policy.call }

    context "when the cooldown has elapsed" do
      let(:bumped_at) { 25.hours.ago }

      it { is_expected.to eq(true) }
    end

    context "when the cooldown has not elapsed" do
      it { is_expected.to eq(false) }
    end
  end

  describe "#reason" do
    subject(:reason) { policy.reason }

    context "with more than two days remaining" do
      before { SiteSetting.topic_owner_bump_cooldown_minutes = 7.days.in_minutes }

      it { is_expected.to eq("You can bump this topic again in 7 days.") }
    end

    context "with between one and two days remaining" do
      before { SiteSetting.topic_owner_bump_cooldown_minutes = 2.days.in_minutes }

      it { is_expected.to eq("You can bump this topic again in 47 hours.") }
    end

    context "with several hours remaining" do
      it { is_expected.to eq("You can bump this topic again in 23 hours.") }
    end

    context "with exactly one hour remaining" do
      let(:bumped_at) { 23.hours.ago }

      it { is_expected.to eq("You can bump this topic again in 1 hour.") }
    end

    context "with less than an hour remaining" do
      let(:bumped_at) { 23.hours.ago - 30.minutes }

      it { is_expected.to eq("You can bump this topic again in 30 minutes.") }
    end

    context "with less than a minute remaining" do
      let(:bumped_at) { 24.hours.ago + 30.seconds }

      it { is_expected.to eq("You can bump this topic again in 1 minute.") }
    end
  end
end
