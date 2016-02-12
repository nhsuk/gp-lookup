require "haversine"

class LocationSearchIndex
  def initialize(practices:, max_results: 10)
    @practices = practices
      .map(&Practice.method(:new))
      .select(&:has_coordinates?)

    @max_results = max_results
  end

  def find(latitude, longitude)
    practices
      .sort_by { |practice| practice.distance_from(latitude, longitude) }
      .take(max_results)
      .map { |practice| format_result(practice, latitude, longitude) }
  end

private
  attr_reader :practices, :max_results

  def format_result(practice, latitude, longitude)
    {
      code: practice.data.fetch(:code),
      name: {
        value: practice.data.fetch(:name),
        matches: [],
      },
      address: {
        value: practice.data.fetch(:location).fetch(:address),
        matches: [],
      },
      practitioners: [],
      score: {
        distance: practice.distance_from(latitude, longitude).to_miles.round(1),
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

    def distance_from(other_latitude, other_longitude)
      Haversine.distance(latitude.to_f, longitude.to_f, other_latitude, other_longitude)
    rescue
      puts data.inspect
      raise
    end

  private
    def latitude
      data.fetch(:location).fetch(:latitude, nil)
    rescue
      puts data.inspect
      raise
    end

    def longitude
      data.fetch(:location).fetch(:longitude, nil)
    end
  end
end
