require "practice_data_transformer"

RSpec.describe(PracticeDataTransformer, "#call") do
  subject(:transformer) {
    PracticeDataTransformer.new(
      practices: practices,
      practitioners: practitioners,
    )
  }

  let(:practices) {
    [
      puddleton_practice,
      lakeside_practice,
    ]
  }
  let(:practitioners) { [] }

  let(:puddleton_practice) {
    {
      organisation_code: puddleton_organisation_code,
      name: puddleton_name,
      address: puddleton_address,
      contact_telephone_number: puddleton_phone_number,
    }
  }

  let(:lakeside_practice) {
    {
      organisation_code: lakeside_organisation_code,
      name: lakeside_name,
      address: lakeside_address,
      contact_telephone_number: lakeside_phone_number,
    }
  }

  let(:puddleton_organisation_code) { double }
  let(:puddleton_name) { double }
  let(:puddleton_address) { double }
  let(:puddleton_phone_number) { double }

  let(:lakeside_organisation_code) { double }
  let(:lakeside_name) { double }
  let(:lakeside_address) { double }
  let(:lakeside_phone_number) { double }

  it "should transform practice data keys" do
    expect(transformer.call).to eq([
      {
        code: puddleton_organisation_code,
        name: puddleton_name,
        address: puddleton_address,
        practitioners: [],
      },
      {
        code: lakeside_organisation_code,
        name: lakeside_name,
        address: lakeside_address,
        practitioners: [],
      },
    ])
  end
end
