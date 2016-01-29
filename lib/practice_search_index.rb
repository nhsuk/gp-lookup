require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:, max_results: 10)
    @practices = practices
    @max_results = max_results

    build_haystacks
  end

  def find(search_term)
    names_results = names_haystack.find(search_term, max_results)
    names_results = names_results.map { |index, matches, _weight|
      practices.fetch(index).merge(
        score: {
          name: matches,
        },
      )
    }

    addresses_results = addresses_haystack.find(search_term, max_results)
    addresses_results = addresses_results.map { |index, matches, _weight|
      practices.fetch(index).merge(
        score: {
          address: matches,
        },
      )
    }

    combined_results = names_results + addresses_results

    deduped_results = combined_results.reduce({}) { |results, practice|
      code = practice.fetch(:code)

      results.merge(code => practice) { |_code, oldval, newval|
        score = oldval.fetch(:score).merge(newval.fetch(:score))

        oldval.merge(score: score)
      }
    }.values

    deduped_results.map { |practice_result|
      name = practice_result.fetch(:name)
      address = practice_result.fetch(:address)
      score = practice_result.fetch(:score)

      practice_result.merge(
        name: {
          value: name,
          matches: substring_indices(name, search_term),
        },
        address: {
          value: address,
          matches: substring_indices(address, search_term),
        },
        score: {
          name: 0,
          address: 0,
        }.merge(score),
      )
    }
  end

private
  attr_reader(
    :practices,
    :max_results,
    :names_haystack,
    :addresses_haystack,
  )

  def build_haystacks
    @names_haystack = Blurrily::Map.new
    practices.each.with_index do |practice, index|
      names_haystack.put(practice.fetch(:name), index)
    end

    @addresses_haystack = Blurrily::Map.new
    practices.each.with_index do |practice, index|
      addresses_haystack.put(practice.fetch(:address), index)
    end
  end

  def substring_indices(string, substring)
    string
      .downcase
      .each_char
      .each_cons(substring.length)
      .with_index
      .select { |chars, _index| chars.join == substring.downcase }
      .map { |_chars, index| [index, index + substring.length - 1] }
  end
end
