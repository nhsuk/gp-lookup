require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:)
    @practices = practices

    build_index
  end

  def find(search_term)
    map.find(search_term).map { |index, matches, weight|
      practices.fetch(index).merge(
        score: {
          matches: matches,
          weight: weight,
        },
      )
    }
  end

private
  attr_reader :practices, :map

  def build_index
    @map = Blurrily::Map.new

    practices.each.with_index do |practice, index|
      needle = [
        practice.fetch("name"),
        practice.fetch("address"),
      ].join(", ")

      map.put(needle, index)
    end
  end
end
