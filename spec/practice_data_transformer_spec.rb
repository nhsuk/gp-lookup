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
      location: puddleton_location,
      contact_telephone_number: puddleton_phone_number,
    }
  }

  let(:puddleton_location) {
    {
      address: puddleton_address,
      postcode: puddleton_postcode,
      latitude: puddleton_latitude,
      longitude: puddleton_longitude,
    }
  }

  let(:lakeside_practice) {
    {
      organisation_code: lakeside_organisation_code,
      name: lakeside_name,
      location: lakeside_location,
      contact_telephone_number: lakeside_phone_number,
    }
  }

  let(:lakeside_location) {
    {
      address: lakeside_address,
      postcode: lakeside_postcode,
    }
  }

  let(:puddleton_organisation_code) { "H81600" }
  let(:puddleton_name) { double }
  let(:puddleton_address) { double }
  let(:puddleton_postcode) { double }
  let(:puddleton_latitude) { double }
  let(:puddleton_longitude) { double }
  let(:puddleton_phone_number) { double }

  let(:lakeside_organisation_code) { "L84040" }
  let(:lakeside_name) { double }
  let(:lakeside_address) { double }
  let(:lakeside_postcode) { double }
  let(:lakeside_phone_number) { double }

  let(:dr_abacus) {
    {
      general_medical_practitioner_code: double,
      name: dr_abacus_name,
      practice: "general-medical-practice:#{puddleton_organisation_code}",
    }
  }

  let(:dr_butter) {
    {
      general_medical_practitioner_code: double,
      name: dr_butter_name,
      practice: "general-medical-practice:#{puddleton_organisation_code}",
    }
  }

  let(:dr_calais) {
    {
      general_medical_practitioner_code: double,
      name: dr_calais_name,
      practice: "general-medical-practice:#{lakeside_organisation_code}",
    }
  }

  let(:dr_abacus_name) { double }
  let(:dr_butter_name) { double }
  let(:dr_calais_name) { double }

  it "should transform practice data keys" do
    expect(transformer.call).to eq([
      {
        code: puddleton_organisation_code,
        name: puddleton_name,
        location: puddleton_location,
        practitioners: [],
      },
      {
        code: lakeside_organisation_code,
        name: lakeside_name,
        location: lakeside_location,
        practitioners: [],
      },
    ])
  end

  context "with practitioners" do
    let(:practitioners) {
      [
        dr_abacus,
        dr_butter,
        dr_calais,
      ]
    }

    it "should associate the practitioners with the right practice" do
      expect(transformer.call).to eq([
        {
          code: puddleton_organisation_code,
          name: puddleton_name,
          location: puddleton_location,
          practitioners: [
            dr_abacus_name,
            dr_butter_name,
          ],
        },
        {
          code: lakeside_organisation_code,
          name: lakeside_name,
          location: lakeside_location,
          practitioners: [
            dr_calais_name,
          ],
        },
      ])
    end
  end

  context "with practitioners for non-existent practices" do
    let(:practices) {
      [
        lakeside_practice,
      ]
    }

    let(:practitioners) {
      [
        dr_abacus,
        dr_butter,
        dr_calais,
      ]
    }

    it "should omit the practitioners" do
      expect(transformer.call).to eq([
        {
          code: lakeside_organisation_code,
          name: lakeside_name,
          location: lakeside_location,
          practitioners: [
            dr_calais_name,
          ],
        },
      ])
    end
  end
end
