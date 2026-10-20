# frozen_string_literal: true

RSpec.describe TopicsController do
  fab!(:owner) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category, :topic_owner_bump_category)
  fab!(:topic) { create_post(user: owner, category:, created_at: 2.days.ago).topic }

  let(:serialized_field) { "owner_bump_available_at" }

  before { enable_current_plugin }

  describe "#show" do
    it "tells the topic owner when they can bump the topic" do
      sign_in(owner)

      get "/t/#{topic.id}.json"

      expect(response.status).to eq(200)
      expect(Time.zone.parse(response.parsed_body[serialized_field])).to eq_time(
        topic.bumped_at + 24.hours,
      )
    end

    it "does not tell other users when the topic can be bumped" do
      sign_in(Fabricate(:user))

      get "/t/#{topic.id}.json"

      expect(response.parsed_body).not_to have_key(serialized_field)
    end

    it "does not tell admins who do not own the topic when it can be bumped" do
      sign_in(Fabricate(:admin))

      get "/t/#{topic.id}.json"

      expect(response.parsed_body).not_to have_key(serialized_field)
    end

    it "does not tell anonymous users when the topic can be bumped" do
      get "/t/#{topic.id}.json"

      expect(response.parsed_body).not_to have_key(serialized_field)
    end

    it "does not tell the topic owner when the plugin is disabled" do
      SiteSetting.discourse_modifications_enabled = false
      sign_in(owner)

      get "/t/#{topic.id}.json"

      expect(response.parsed_body).not_to have_key(serialized_field)
    end
  end
end
