# frozen_string_literal: true

RSpec.describe "Slug.ascii_generator AnyAscii patch" do
  before do
    allow(SiteSetting).to receive(:slug_generation_method).and_return("ascii")
    allow(SiteSetting).to receive(:default_locale).and_return("en")
  end

  it "transliterates mathematical bold/italic Unicode to ASCII" do
    title = "𝑻𝒉𝒆 𝒔𝒖𝒎𝒎𝒆𝒓 𝒘𝒆 𝒇𝒆𝒍𝒍 𝒊𝒏 𝒍𝒐𝒗𝒆 [𝐇𝐀𝐈𝐊𝐘𝐔]"
    expect(Slug.for(title)).to eq("the-summer-we-fell-in-love-haikyu")
  end

  it "still handles plain ASCII titles" do
    expect(Slug.for("Hello World")).to eq("hello-world")
  end

  it "still handles accented characters" do
    expect(Slug.for("Café au lait")).to eq("cafe-au-lait")
  end

  it "falls back to the default when slug is blank after transliteration" do
    expect(Slug.for(":smile:")).to eq("topic")
  end

  it "is not applied when slug_generation_method is encoded" do
    allow(SiteSetting).to receive(:slug_generation_method).and_return("encoded")
    expect(Slug.for("Héllo")).to eq("h%C3%A9llo")
  end
end
