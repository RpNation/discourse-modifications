# frozen_string_literal: true

RSpec.describe DiscourseRpn::TopicBumpsController do
  fab!(:owner) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category, :topic_owner_bump_category)
  fab!(:topic) { create_post(user: owner, category:, created_at: 2.days.ago).topic }

  before { enable_current_plugin }

  describe "#create" do
    context "when not logged in" do
      it "returns a 403" do
        post "/discourse-rpn/topics/#{topic.id}/bump.json"

        expect(response.status).to eq(403)
      end
    end

    context "when logged in as the topic owner" do
      before do
        freeze_time
        sign_in(owner)
      end

      it "bumps the topic and returns when it can be bumped again" do
        post "/discourse-rpn/topics/#{topic.id}/bump.json"

        expect(response.status).to eq(200)
        expect(Time.zone.parse(response.parsed_body["owner_bump_available_at"])).to eq_time(
          24.hours.from_now,
        )
      end

      it "returns a 422 with the remaining cooldown during the cooldown" do
        topic.update!(bumped_at: 1.hour.ago)

        post "/discourse-rpn/topics/#{topic.id}/bump.json"

        expect(response.status).to eq(422)
        expect(response.parsed_body["errors"]).to contain_exactly(
          "You can bump this topic again in 23 hours.",
        )
      end

      it "returns a 404 when the topic does not exist" do
        post "/discourse-rpn/topics/0/bump.json"

        expect(response.status).to eq(404)
      end

      it "returns a 404 when the plugin is disabled" do
        SiteSetting.discourse_rpn_enabled = false

        post "/discourse-rpn/topics/#{topic.id}/bump.json"

        expect(response.status).to eq(404)
      end
    end

    context "when logged in as another user" do
      fab!(:other_user) { Fabricate(:user, refresh_auto_groups: true) }

      before { sign_in(other_user) }

      it "returns a 403 for a visible topic" do
        post "/discourse-rpn/topics/#{topic.id}/bump.json"

        expect(response.status).to eq(403)
      end

      it "returns the same 404 as a missing topic for a topic they cannot see" do
        post "/discourse-rpn/topics/0/bump.json"
        missing_topic_response = response.parsed_body

        category.set_permissions(staff: :full)
        category.save!
        post "/discourse-rpn/topics/#{topic.id}/bump.json"

        expect(response.status).to eq(404)
        expect(response.parsed_body).to eq(missing_topic_response)
      end
    end
  end
end
