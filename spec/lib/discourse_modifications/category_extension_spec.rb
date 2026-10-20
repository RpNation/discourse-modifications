# frozen_string_literal: true

RSpec.describe DiscourseModifications::CategoryExtension do
  fab!(:category)

  describe "#topic_owner_bump_enabled?" do
    it "returns true when the category has opted in" do
      category.custom_fields[DiscourseModifications::TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD] = true
      category.save_custom_fields

      expect(category.reload.topic_owner_bump_enabled?).to eq(true)
    end

    it "returns false when the category has opted out" do
      category.custom_fields[DiscourseModifications::TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD] = false
      category.save_custom_fields

      expect(category.reload.topic_owner_bump_enabled?).to eq(false)
    end

    it "returns false when the category has never been configured" do
      expect(category.topic_owner_bump_enabled?).to eq(false)
    end

    it "returns true for a subcategory whose parent has opted in" do
      category.custom_fields[DiscourseModifications::TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD] = true
      category.save_custom_fields
      subcategory = Fabricate(:category, parent_category: category)

      expect(subcategory.topic_owner_bump_enabled?).to eq(true)
    end

    it "returns true for a subcategory whose grandparent has opted in" do
      SiteSetting.max_category_nesting = 3
      category.custom_fields[DiscourseModifications::TOPIC_OWNER_BUMP_ENABLED_CUSTOM_FIELD] = true
      category.save_custom_fields
      subcategory = Fabricate(:category, parent_category: category)
      sub_subcategory = Fabricate(:category, parent_category: subcategory)

      expect(sub_subcategory.topic_owner_bump_enabled?).to eq(true)
    end

    it "returns false for a subcategory whose parent has not opted in" do
      subcategory = Fabricate(:category, parent_category: category)

      expect(subcategory.topic_owner_bump_enabled?).to eq(false)
    end
  end
end
