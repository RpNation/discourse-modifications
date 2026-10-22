# frozen_string_literal: true

RSpec.describe "Locked minimum watch categories" do
  fab!(:user)
  fab!(:category)
  fab!(:other_category, :category)

  let(:levels) { CategoryUser.notification_levels }

  before do
    SiteSetting.discourse_rpn_enabled = true
    SiteSetting.locked_min_watch_categories = category.id.to_s
    DiscourseRpn::ForcedCategoryWatching.enforce(user)
    sign_in(user)
  end

  describe "POST /category/:category_id/notifications" do
    %i[muted regular tracking].each do |level|
      it "rejects #{level}" do
        post "/category/#{category.id}/notifications.json",
             params: {
               notification_level: levels[level],
             }

        expect(response.status).to eq(403)
        expect(response.parsed_body["errors"]).to include(
          I18n.t("discourse_rpn.locked_watch_category"),
        )
        expect(CategoryUser.find_by(user:, category:).notification_level).to eq(
          levels[:watching_first_post],
        )
      end
    end

    it "allows watching first post" do
      post "/category/#{category.id}/notifications.json",
           params: {
             notification_level: levels[:watching_first_post],
           }

      expect(response.status).to eq(200)
    end

    it "allows watching" do
      post "/category/#{category.id}/notifications.json",
           params: {
             notification_level: levels[:watching],
           }

      expect(response.status).to eq(200)
      expect(CategoryUser.find_by(user:, category:).notification_level).to eq(levels[:watching])
    end

    it "does not restrict other categories" do
      post "/category/#{other_category.id}/notifications.json",
           params: {
             notification_level: levels[:muted],
           }

      expect(response.status).to eq(200)
    end
  end

  describe "PUT /u/:username" do
    %i[tracked_category_ids muted_category_ids regular_category_ids].each do |attribute|
      it "rejects placing the category in #{attribute}" do
        put "/u/#{user.username}.json", params: { attribute => [category.id] }

        expect(response.status).to eq(403)
        expect(response.parsed_body["errors"]).to include(
          I18n.t("discourse_rpn.locked_watch_category"),
        )
      end
    end

    it "allows watching the category" do
      put "/u/#{user.username}.json", params: { watched_category_ids: [category.id] }

      expect(response.status).to eq(200)
      expect(CategoryUser.find_by(user:, category:).notification_level).to eq(levels[:watching])
    end

    it "allows watching the category first post" do
      put "/u/#{user.username}.json", params: { watched_first_post_category_ids: [category.id] }

      expect(response.status).to eq(200)
    end

    it "keeps the category watched when it is left out of the watched lists" do
      put "/u/#{user.username}.json",
          params: {
            watched_first_post_category_ids: [other_category.id],
            watched_category_ids: [""],
          }

      expect(response.status).to eq(200)
      expect(CategoryUser.find_by(user:, category:).notification_level).to eq(
        levels[:watching_first_post],
      )
    end

    it "does not restrict other categories" do
      put "/u/#{user.username}.json", params: { muted_category_ids: [other_category.id] }

      expect(response.status).to eq(200)
    end
  end

  context "when the plugin is disabled" do
    before { SiteSetting.discourse_rpn_enabled = false }

    it "allows lowering the level from the category" do
      post "/category/#{category.id}/notifications.json",
           params: {
             notification_level: levels[:muted],
           }

      expect(response.status).to eq(200)
      expect(CategoryUser.find_by(user:, category:).notification_level).to eq(levels[:muted])
    end

    it "allows lowering the level from preferences" do
      put "/u/#{user.username}.json", params: { muted_category_ids: [category.id] }

      expect(response.status).to eq(200)
      expect(CategoryUser.find_by(user:, category:).notification_level).to eq(levels[:muted])
    end
  end
end
