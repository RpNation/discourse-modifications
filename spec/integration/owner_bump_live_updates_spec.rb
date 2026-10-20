# frozen_string_literal: true

RSpec.describe "Owner bump live updates" do
  fab!(:owner) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:replier) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:admin)
  fab!(:category, :topic_owner_bump_category)
  fab!(:topic) { create_post(user: owner, category:, created_at: 2.days.ago).topic }

  before do
    enable_current_plugin
    freeze_time
  end

  def owner_bump_messages(&)
    MessageBus
      .track_publish("/topic/#{topic.id}", &)
      .select { |message| message.data[:type] == DiscourseModifications::OWNER_BUMP_MESSAGE_TYPE }
  end

  it "sends the owner the restarted cooldown when someone replies" do
    messages = owner_bump_messages { create_post(user: replier, topic:) }

    expect(messages.map(&:user_ids)).to eq([[owner.id]])
    expect(messages.first.data[:owner_bump_available_at]).to eq_time(24.hours.from_now)
  end

  it "sends the owner the rewound cooldown when the latest reply is deleted" do
    reply = create_post(user: replier, topic:)

    messages = owner_bump_messages { PostDestroyer.new(admin, reply).destroy }

    expect(messages.map { |message| message.data[:owner_bump_available_at] }).to eq(
      [topic.reload.owner_bump_available_at],
    )
  end

  it "sends nothing for a whisper" do
    SiteSetting.whispers_allowed_groups = Group::AUTO_GROUPS[:staff].to_s

    messages =
      owner_bump_messages { create_post(user: admin, topic:, post_type: Post.types[:whisper]) }

    expect(messages).to be_empty
  end

  it "sends nothing when the owner can't bump the topic" do
    category.custom_fields[DiscourseModifications::TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD] = false
    category.save_custom_fields

    messages = owner_bump_messages { create_post(user: replier, topic:) }

    expect(messages).to be_empty
  end

  it "sends nothing when the plugin is disabled" do
    SiteSetting.discourse_modifications_enabled = false

    messages = owner_bump_messages { create_post(user: replier, topic:) }

    expect(messages).to be_empty
  end
end
