require "json"
require "sinatra"

PRACTICES = JSON.parse(File.read("data/general-medical-practices.json"))

def all_practices
  PRACTICES
end

def practices_matching(search_term)
  all_practices.select { |practice|
    practice.fetch("name").downcase.include?(search_term)
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
