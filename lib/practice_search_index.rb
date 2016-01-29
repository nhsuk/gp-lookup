require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:, max_results: 10)
    @practices = practices
    @max_results = max_results

    build_haystacks
  end

  def find(search_term)
    results = practices_haystack.find(search_term, max_results)

    results.map { |index, matches, _weight|
      practices.fetch(index).merge(
        score: {
          name: matches,
        }
      )
    }
  end

private
  attr_reader(
    :practices,
    :practices_haystack,
    :max_results,
  )

  def build_haystacks
    @practices_haystack = Blurrily::Map.new
    practices.each.with_index do |practice, index|
      practices_haystack.put(practice.fetch(:name), index)
    end
  end
end
