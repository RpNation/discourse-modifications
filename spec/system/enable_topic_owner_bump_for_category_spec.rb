# frozen_string_literal: true

RSpec.describe "Enable topic owner bump for category" do
  fab!(:admin)
  fab!(:category)

  let(:category_page) { PageObjects::Pages::Category.new }
  let(:form) { PageObjects::Components::FormKit.new(".form-kit") }
  let(:bump_field) { form.field("custom_fields.topic_owner_bump_enabled") }
  let(:toasts) { PageObjects::Components::Toasts.new }

  before do
    enable_current_plugin
    sign_in(admin)
  end

  it "lets the admin allow topic owners to bump their topics in a category" do
    category_page.visit_settings(category)

    bump_field.toggle
    category_page.save_settings

    expect(toasts).to have_success(I18n.t("js.saved"))

    page.refresh

    expect(bump_field).to be_checked
  end
end
