require "blurrily/map"
require "json"
require "sinatra"

PRACTICES = JSON.parse(File.read("data/general-medical-practices.json"))

SEARCH_INDEX = Blurrily::Map.new
PRACTICES.each.with_index do |practice, index|
  SEARCH_INDEX.put(practice.fetch("name"), index)
end

def all_practices
  PRACTICES
end

def practices_matching(search_term)
  SEARCH_INDEX.find(search_term).map { |index, _, _|
    PRACTICES.fetch(index)
  }
end

get "/practices" do
  search_term = params.fetch("search", "").downcase

  practices = if search_term.empty?
    all_practices
  else
    practices_matching(search_term)
  end

  content_type :json
  practices.to_json
end
