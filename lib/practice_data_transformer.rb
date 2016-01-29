class PracticeDataTransformer
  def initialize(practices:, practitioners:)
    @practices = practices
    @practitioners = practitioners
  end

  def call
    practices.map { |practice|
      {
        code: practice.fetch(:organisation_code),
        name: practice.fetch(:name),
        address: practice.fetch(:address),
        practitioners: [],
      }
    }
  end

private
  attr_reader :practices
end
