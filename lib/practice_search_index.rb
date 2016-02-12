require "postcodes_io"

require "./lib/fuzzy_search_index"
require "./lib/location_search_index"

class PracticeSearchIndex
  def initialize(practices:, max_results: 10)
    @fuzzy_search_index = FuzzySearchIndex.new(
      practices: practices,
      max_results: max_results,
    )

    @location_search_index = LocationSearchIndex.new(
      practices: practices,
      max_results: max_results,
    )

    # TODO use local data
    @postcodes = Postcodes::IO.new
  end

  def find(search_term)
    postcode = postcodes.lookup(search_term)

    if postcode
      location_search_index.find(postcode)
    else
      fuzzy_search_index.find(search_term)
    end
  end

private
  attr_reader(
    :fuzzy_search_index,
    :location_search_index,
    :postcodes,
  )
end
