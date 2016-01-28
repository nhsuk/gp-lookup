require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:)
    @practices = practices

    build_index
  end

  def find(search_term)
    search_haystacks(search_term).sort_by { |result|
      -result.fetch(:score).fetch(:matches)
    }
  end

  def search_haystacks(search_term)
    [
      find_practices(search_term),
    ].reduce(:+)
  end

private
  attr_reader :practices, :practices_haystack

  def build_index
    @practices_haystack = Blurrily::Map.new

    practices.each.with_index do |practice, index|
      needle = [
        practice.fetch("name"),
        practice.fetch("address"),
      ].join(", ")

      practices_haystack.put(needle, index)
    end
  end

  def find_practices(search_term)
    practices_haystack.find(search_term).map { |index, matches, weight|
      practices.fetch(index).merge(
        score: {
          matches: matches,
          weight: weight,
        },
      )
    }
  end
end
