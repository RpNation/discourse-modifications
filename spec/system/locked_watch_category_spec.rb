# frozen_string_literal: true

RSpec.describe "Locked minimum watch categories" do
  fab!(:user)
  fab!(:locked_category, :category)
  fab!(:other_category, :category)

  let(:category_page) { PageObjects::Pages::Category.new }
  let(:notifications_tracking) do
    PageObjects::Components::NotificationsTracking.new(".category-notifications-tracking")
  end

  before do
    enable_current_plugin
    SiteSetting.locked_min_watch_categories = locked_category.id.to_s
    DiscourseRpn::ForcedCategoryWatching.enforce(user)
    sign_in(user)
  end

  it "only offers the watching levels on a locked category" do
    category_page.visit(locked_category)
    notifications_tracking.toggle

    %w[watching watching_first_post].each do |level|
      expect(notifications_tracking.content).to have_css("[data-level-name='#{level}']")
    end
    %w[muted regular tracking].each do |level|
      expect(notifications_tracking.content).to have_no_css("[data-level-name='#{level}']")
    end
  end

  it "offers every level on other categories" do
    category_page.visit(other_category)
    notifications_tracking.toggle

    expect(notifications_tracking.content).to have_css("[data-level-name='muted']")
  end
end
