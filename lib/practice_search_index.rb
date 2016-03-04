require "faraday"
require "faraday_middleware"

require "./lib/fuzzy_search_index"
require "./lib/location_search_index"
require "./lib/outcodes_search_index"
require "./lib/postcode_lookup.rb"

class PracticeSearchIndex
  def initialize(practices:)
    @fuzzy_search_index = FuzzySearchIndex.new(
      practices: practices,
    )

    @location_search_index = LocationSearchIndex.new(
      practices: practices,
    )

    @outcodes_search_index = OutcodesSearchIndex.new(
      practices: practices,
    )

    @postcodes = PostcodeLookup.new(
      http_client: postcode_lookup_client,
    )
  end

  def find(search_term, max_results: 10)
    postcode = postcodes.find(search_term)

    if postcode.postcode?
      location_search_index.find(postcode, max_results: max_results)
    elsif postcode.outcode?
      outcodes_search_index.find(postcode.outcode)
    else
      fuzzy_search_index.find(search_term, max_results: max_results)
    end
  end

private
  attr_reader(
    :fuzzy_search_index,
    :location_search_index,
    :outcodes_search_index,
    :postcodes,
  )

  def postcode_lookup_client
    # TODO use local data
    Faraday.new(url: "https://api.postcodes.io") do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.use FaradayMiddleware::ParseJson
    end
  end
end
