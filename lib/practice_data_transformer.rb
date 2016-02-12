class PracticeDataTransformer
  def initialize(practices:, practitioners:)
    @practices = practices
    @practitioners = practitioners
  end

  def call
    practices.map { |practice|
      code = practice.fetch(:organisation_code)

      {
        code: code,
        name: practice.fetch(:name),
        location: practice.fetch(:location),
        practitioners: practitioners_map.fetch(code, []),
      }
    }
  end

private
  attr_reader :practices, :practitioners

  def practitioners_map
    @practitioners_map ||= build_practitioners_map
  end

  def build_practitioners_map
    practitioners.each.with_object({}) do |practitioner, map|
      key = practitioner.fetch(:practice).sub("general-medical-practice:", "")
      map[key] ||= []

      practitioner_name = practitioner.fetch(:name)
      map[key].push(practitioner_name)
    end
  end
end
