require "practice_search_index"

RSpec.describe(PracticeSearchIndex, "#find") do
  subject(:index) {
    PracticeSearchIndex.new(
      practices: practices,
      max_results: 10,
    )
  }

  let(:practices) {
    [
      heathcote_medical_centre,
    ]
  }

  let(:heathcote_medical_centre) {
    {
      code: "H81070",
      name: "Heathcote Medical Centre",
      address: "Heathcote, Tadworth, Surrey, KT20 5TH",
    }
  }

  context "with no matches" do
    it "returns an empty array" do
      expect(index.find("xyz")).to eq([])
    end
  end

  context "with one match for the practice name" do
    it "returns one result" do
      expect(index.find("medical")).to eq(
        [
          {
            code: "H81070",
            name: "Heathcote Medical Centre",
            address: "Heathcote, Tadworth, Surrey, KT20 5TH",
          }
        ]
      )
    end
  end
end
