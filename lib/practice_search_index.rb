require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:, max_results: 10)
    @practices = practices
    @practitioners = practices.flat_map.with_index { |practice, practice_index|
      practice.fetch(:practitioners).map { |practitioner|
        {
          name: practitioner,
          practice_index: practice_index,
        }
      }
    }

    @max_results = max_results

    build_haystacks
  end

  def find(search_term)
    practice_results = Hash.new { |hash, index|
      hash[index] = []
    }

    names_haystack.find(search_term, max_results).each do |index, matches, _weight|
      result = practice_results[index]
      name = practices.fetch(index).fetch(:name)

      result.push(
        {
          property: :name,
          value: name,
          matches: substring_indices(name, search_term),
          score: matches,
        }
      )
    end

    addresses_haystack.find(search_term, max_results).each do |index, matches, _weight|
      result = practice_results[index]
      address = practices.fetch(index).fetch(:address)

      result.push(
        {
          property: :address,
          value: address,
          matches: substring_indices(address, search_term),
          score: matches,
        }
      )
    end

    practitioners_haystack.find(search_term, max_results).each do |index, matches, _weight|
      practitioner = practitioners.fetch(index)
      name = practitioner.fetch(:name)
      result = practice_results[practitioner.fetch(:practice_index)]

      result.push(
        {
          property: :practitioners,
          value: name,
          matches: substring_indices(name, search_term),
          score: matches,
        }
      )
    end

    practice_results.map { |(index, results)|
      format_practice_result(
        practices.fetch(index),
        results,
      )
    }
  end

private
  attr_reader(
    :practices,
    :practitioners,
    :max_results,
    :names_haystack,
    :addresses_haystack,
    :practitioners_haystack,
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

    @practitioners_haystack = Blurrily::Map.new
    practitioners.each.with_index do |practitioner, index|
      practitioners_haystack.put(practitioner.fetch(:name), index)
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

  def format_practice_result(practice, results)
    name_result = results.find { |result|
      result.fetch(:property) == :name
    } || {
      matches: [],
      score: 0,
    }

    address_result = results.find { |result|
      result.fetch(:property) == :address
    } || {
      matches: [],
      score: 0,
    }

    practitioners_results = results.select { |result|
      result.fetch(:property) == :practitioners
    }

    practitioners_score = practitioners_results.map { |result|
      result.fetch(:score)
    }.max || 0

    practitioners_list = practitioners_results.map { |result|
      {
        value: result.fetch(:value),
        matches: result.fetch(:matches),
      }
    }

    {
      code: practice.fetch(:code),
      name: {
        value: practice.fetch(:name),
        matches: name_result.fetch(:matches),
      },
      address: {
        value: practice.fetch(:address),
        matches: address_result.fetch(:matches),
      },
      practitioners: practitioners_list,
      score: {
        name: name_result.fetch(:score),
        address: address_result.fetch(:score),
        practitioners: practitioners_score,
      },
    }
  end
end
