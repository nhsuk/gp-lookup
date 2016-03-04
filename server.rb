require "json"
require "sinatra"

require "./lib/practice_search_index"
require "./lib/practice_data_transformer"
require "./lib/react/exec_js_renderer"

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
  SEARCH_INDEX.find(search_term.downcase, max_results: 20)
end

def find_practice(organisation_code)
  OpenStruct.new(
    PRACTICES.find { |practice|
      practice.fetch(:organisation_code) == organisation_code
    }
  )
end

get '/' do
  search_term = params.fetch("search", "")
  practices = search_term.empty? ? nil : practices_matching(search_term)

  erb :index, locals: {
    search_term: search_term,
    practices: practices,
  }
end

get "/practices" do
  search_term = params.fetch("search", "")

  practices = if search_term.empty?
    all_practices
  else
    practices_matching(search_term)
  end

  content_type :json
  JSON.pretty_generate(practices)
end

get "/book/:organisation_code" do
  practice = find_practice(params.fetch("organisation_code"))

  erb :book, locals: { practice: practice }
end

get "/type-2-diabetes/going-for-regular-check-ups" do
  erb :regular_check_ups
end

helpers do
  def react_component(component_name, props = {})
    renderer = React::ExecJSRenderer.new(
      ["public/javascripts/components.js"]
    )

    renderer.render(component_name, props)
  end
end
