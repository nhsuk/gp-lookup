require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:, practitioners:, max_results: 10)
    @practices = practices
    @practitioners = get_practitioners_linked_to_practices(practitioners)
    @max_results = max_results

    build_haystacks
  end

  def find(search_term)
    search_haystacks(search_term).sort_by { |result|
      -result.fetch(:score).fetch(:matches)
    }.take(max_results)
  end

  def search_haystacks(search_term)
    [
      find_practices(search_term),
      find_addresses(search_term),
      find_practitioners(search_term),
    ].reduce(:+)
  end

private
  attr_reader(
    :practices,
    :practitioners,
    :practices_haystack,
    :addresses_haystack,
    :practitioners_haystack,
    :max_results,
  )

  def get_practitioners_linked_to_practices(practitioners)
    practice_map = {}
    practices.each do |practice|
      practice_map[practice.fetch(:organisation_code)] = practice
    end

    linked_practitioners = practitioners.map { |practitioner|
      practice_id = practitioner.fetch(:practice).sub("general-medical-practice:", "")
      practice = practice_map.fetch(practice_id, nil)

      practitioner.merge(
        practice: practice
      )
    }

    linked_practitioners.select { |practitioner|
      practitioner.fetch(:practice)
    }
  end

  def build_haystacks
    @practices_haystack = Blurrily::Map.new
    practices.each.with_index do |practice, index|
      practices_haystack.put(practice.fetch(:name), index)
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

  def find_practices(search_term)
    results = practices_haystack.find(search_term, max_results)

    results.map { |index, matches, weight|
      practices.fetch(index).merge(
        result_type: :practice,
        score: {
          matches: matches,
          weight: weight,
        },
      )
    }
  end

  def find_addresses(search_term)
    results = addresses_haystack.find(search_term, max_results)

    results.map { |index, matches, weight|
      practices.fetch(index).merge(
        result_type: :address,
        score: {
          matches: matches,
          weight: weight,
        },
      )
    }
  end

  def find_practitioners(search_term)
    results = practitioners_haystack.find(search_term)

    results.map { |index, matches, weight|
      practitioners.fetch(index).merge(
        result_type: :practitioner,
        score: {
          matches: matches,
          weight: weight,
        },
      )
    }
  end
end
