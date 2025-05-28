# frozen_string_literal: true

RSpec.configure { |c| c.filter_run_when_matching :focus }

RSpec.describe DiscourseModifications::TopicSlug do
  let(:topic) { Fabricate(:topic, id: 42) }

  describe ".slug_for_topic" do
    before do
      # Default to ascii slug generation
      allow(SiteSetting).to receive(:slug_generation_method).and_return("ascii")
    end

    it "removes emoji codes from the title" do
      title = "Hello :smile: World"
      slug = "hello-world"
      expect(described_class.slug_for_topic(topic, slug, title)).to eq("hello-world")
    end

    it "unicode normalizes the title" do
      title = "Café"
      slug = "cafe"
      expect(described_class.slug_for_topic(topic, slug, title)).to eq("cafe")
    end

    it "returns the original slug if slug_generation_method is not ascii" do
      allow(SiteSetting).to receive(:slug_generation_method).and_return("encoded")
      expect(described_class.slug_for_topic(topic, "original-slug", "Some Title")).to eq("original-slug")
    end

    it "returns a fallback slug if the result is blank" do
      title = ":smile:"
      slug = ""
      expect(described_class.slug_for_topic(topic, slug, title)).to eq("topic-42")
    end

    it "returns a fallback slug if the result is only numbers" do
      title = "123456"
      slug = "123456"
      expect(described_class.slug_for_topic(topic, slug, title)).to eq("topic-42")
    end

    it "truncates the slug to the max length" do
      long_title = "a" * (Slug::MAX_LENGTH + 10)
      slug = "a" * (Slug::MAX_LENGTH + 10)
      result = described_class.slug_for_topic(topic, slug, long_title)
      expect(result.length).to eq(Slug::MAX_LENGTH)
    end

    it "handles titles with multiple emoji codes" do
      title = "Hello :smile: World :rocket:"
      slug = "hello-world"
      expect(described_class.slug_for_topic(topic, slug, title)).to eq("hello-world")
    end

    it "handles titles with emoji codes with t modifier" do
      title = "Hello :wave:t2: World"
      slug = "hello-world"
      expect(described_class.slug_for_topic(topic, slug, title)).to eq("hello-world")
    end
  end
end