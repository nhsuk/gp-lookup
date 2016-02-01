require "json"
require "sinatra"

require "./lib/practice_search_index"
require "./lib/practice_data_transformer"

PRACTICES = JSON.parse(
  File.read("data/general-medical-practices.json"),
  symbolize_names: true,
)

PRACTITIONERS = JSON.parse(
  File.read("data/general-medical-practitioners.json"),
  symbolize_names: true,
)

SEARCH_INDEX = PracticeSearchIndex.new(
  practices: PracticeDataTransformer.new(
    practices: PRACTICES,
    practitioners: PRACTITIONERS,
  ).call,
)

def all_practices
  PRACTICES
end

def practices_matching(search_term)
  SEARCH_INDEX.find(search_term)
end

get '/' do
  erb :index
end

get "/practices" do
  search_term = params.fetch("search", "").downcase

  practices = if search_term.empty?
    all_practices
  else
    practices_matching(search_term)
  end

  content_type :json
  JSON.pretty_generate(practices)
end
