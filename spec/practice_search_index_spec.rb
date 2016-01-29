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
end
