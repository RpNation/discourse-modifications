# frozen_string_literal: true

RSpec.describe "Bump own topic" do
  fab!(:owner) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category, :topic_owner_bump_category)
  fab!(:topic) { create_post(user: owner, category:, created_at: 2.days.ago).topic }

  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:bump_button) { PageObjects::Components::TopicOwnerBumpButton.new }
  let(:bump_notice) { PageObjects::Components::TopicOwnerBumpNotice.new }

  before do
    enable_current_plugin
    sign_in(owner)
  end

  it "lets the owner bump their topic once per cooldown" do
    topic_page.visit_topic(topic)

    bump_button.click

    expect(bump_notice).to have_bump_by(owner)
    expect(bump_button).to be_disabled
    expect(bump_button).to have_countdown
  end

  it "restarts the owner's countdown live when someone replies" do
    topic_page.visit_topic(topic)
    expect(bump_button).to be_enabled

    create_post(user: Fabricate(:user, refresh_auto_groups: true), topic:)

    expect(bump_button).to be_disabled
    expect(bump_button).to have_countdown
  end
end
