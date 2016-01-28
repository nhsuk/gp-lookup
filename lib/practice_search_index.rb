require "blurrily/map"

class PracticeSearchIndex
  def initialize(practices:, practitioners:)
    @practices = practices
    @practitioners = get_practitioners_linked_to_practices(practitioners)

    build_haystacks
  end

  def find(search_term)
    search_haystacks(search_term).sort_by { |result|
      -result.fetch(:score).fetch(:matches)
    }
  end

  def search_haystacks(search_term)
    [
      find_practices(search_term),
      find_practitioners(search_term),
    ].reduce(:+)
  end

private
  attr_reader(
    :practices,
    :practices_haystack,
    :practitioners,
    :practitioners_haystack,
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
      needle = [
        practice.fetch(:name),
        practice.fetch(:address),
      ].join(", ")

      practices_haystack.put(needle, index)
    end

    @practitioners_haystack = Blurrily::Map.new

    practitioners.each.with_index do |practitioner, index|
      practitioners_haystack.put(practitioner.fetch(:name), index)
    end
  end

  def find_practices(search_term)
    practices_haystack.find(search_term).map { |index, matches, weight|
      practices.fetch(index).merge(
        result_type: :practice,
        score: {
          matches: matches,
          weight: weight,
        },
      )
    }
  end

  def find_practitioners(search_term)
    practitioners_haystack.find(search_term).map { |index, matches, weight|
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
