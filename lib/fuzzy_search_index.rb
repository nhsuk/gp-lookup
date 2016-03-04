require "blurrily/map"

class FuzzySearchIndex
  def initialize(practices:)
    @practices = practices
    @practitioners = practices.flat_map.with_index { |practice, practice_index|
      practice.fetch(:practitioners).map { |practitioner|
        {
          name: practitioner,
          practice_index: practice_index,
        }
      }
    }

    build_haystacks
  end

  def find(search_term, max_results: 10)
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
          matches: trigram_matches(name, search_term),
          score: matches,
        }
      )
    end

    addresses_haystack.find(search_term, max_results).each do |index, matches, _weight|
      result = practice_results[index]
      address = practices.fetch(index).fetch(:location).fetch(:address)

      result.push(
        {
          property: :address,
          value: address,
          matches: trigram_matches(address, search_term),
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
          matches: trigram_matches(name, search_term),
          score: matches,
        }
      )
    end

    practice_results.map { |(index, results)|
      format_practice_result(
        practices.fetch(index),
        results,
      )
    }.sort_by { |result|
      scores = result.fetch(:score).values

      [
        scores.max,
        scores,
      ]
    }.reverse.take(max_results)
  end

private
  attr_reader(
    :practices,
    :practitioners,
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
      addresses_haystack.put(practice.fetch(:location).fetch(:address), index)
    end

    @practitioners_haystack = Blurrily::Map.new
    practitioners.each.with_index do |practitioner, index|
      practitioners_haystack.put(practitioner.fetch(:name), index)
    end
  end

  def trigram_matches(term, query)
    # break both term and query into trigrams
    haystack = term.downcase.each_char.each_cons(3)
    needles = query.downcase.each_char.each_cons(3)

    # find all the places where the term matches the query
    indices = haystack
      .with_index
      .select { |trigram, _index| needles.include?(trigram) }
      .flat_map { |_trigram, index| [ index, index + 1, index + 2 ] }
      .sort
      .uniq

    # turn it into [start, end] pairs
    indices
      .slice_when { |a, b| a + 1 != b }
      .map { |list| [ list.first, list.last ] }
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

    address = "%{address}, %{postcode}" % {
      address: practice.fetch(:location).fetch(:address),
      postcode: practice.fetch(:location).fetch(:postcode),
    }

    {
      code: practice.fetch(:code),
      name: {
        value: practice.fetch(:name),
        matches: name_result.fetch(:matches),
      },
      address: {
        value: address,
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
