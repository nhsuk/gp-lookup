require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:, practitioners:)
    @practices = practices
    @practitioners = practitioners

    build_haystacks
  end

  def find(search_term)
    search_haystacks(search_term).sort_by { |result|
      -result.fetch(:score).fetch(:matches)
    }
  end

  def search_haystacks(search_term)
    [
      find_practices(search_term),
      find_practitioners(search_term),
    ].reduce(:+)
  end

private
  attr_reader(
    :practices,
    :practices_haystack,
    :practitioners,
    :practitioners_haystack,
  )

  def build_haystacks
    @practices_haystack = Blurrily::Map.new

    practices.each.with_index do |practice, index|
      needle = [
        practice.fetch("name"),
        practice.fetch("address"),
      ].join(", ")

      practices_haystack.put(needle, index)
    end

    @practitioners_haystack = Blurrily::Map.new

    practitioners.each.with_index do |practitioner, index|
      practitioners_haystack.put(practitioner.fetch("name"), index)
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

  def find_practitioners(search_term)
    practitioners_haystack.find(search_term).map { |index, matches, weight|
      practitioners.fetch(index).merge(
        score: {
          matches: matches,
          weight: weight,
        },
      )
    }
  end
end
