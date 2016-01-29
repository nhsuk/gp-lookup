require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:, max_results: 10)
    @practices = practices
    @max_results = max_results

    # build_haystacks
  end

  def find(search_term)
    []
  end
end
