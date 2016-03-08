require "haversine"

class LocationSearchIndex
  def initialize(practices:)
    @practices = practices
      .map(&Practice.method(:new))
      .select(&:has_coordinates?)
  end

  def find(postcode, max_results: 10)
    practices
      .sort_by { |practice| practice.distance_from(postcode) }
      .take(max_results)
      .map { |practice| format_result(practice, postcode) }
  end

private
  attr_reader :practices

  def format_result(practice, postcode)
    address = "%{address}, %{postcode}" % {
      address: practice.data.fetch(:location).fetch(:address),
      postcode: practice.data.fetch(:location).fetch(:postcode),
    }

    {
      code: practice.data.fetch(:code),
      name: {
        value: practice.data.fetch(:name),
        matches: [],
      },
      address: {
        value: address,
        matches: substring_indices(address, postcode.postcode),
      },
      practitioners: [],
      score: {
        distance: practice.distance_from(postcode).to_miles.round(1),
      },
    }
  end

  def substring_indices(string, substring)
    string
      .downcase
      .each_char
      .each_cons(substring.length)
      .with_index
      .select { |chars, _index| chars.join == substring.downcase }
      .map { |_chars, index| [index, index + substring.length - 1] }
  end

  class Practice
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def has_coordinates?
      latitude && longitude
    end

    def distance_from(postcode)
      Haversine.distance(
        latitude.to_f,
        longitude.to_f,
        postcode.latitude,
        postcode.longitude,
      )
    end

  private
    def latitude
      data.fetch(:location).fetch(:latitude, nil)
    end

    def longitude
      data.fetch(:location).fetch(:longitude, nil)
    end
  end
end
