class OutcodesSearchIndex
  def initialize(practices:)
    @practices = practices.group_by { |practice|
      practice.fetch(:location).fetch(:postcode).split(" ").first.upcase
    }
  end

  def find(outcode)
    practices
      .fetch(outcode.upcase, [])
      .sort_by { |practice| practice.fetch(:name) }
      .map { |practice| format_result(practice, outcode) }
  end

private
  attr_reader :practices

  def format_result(practice, outcode)
    address = "%{address}, %{postcode}" % {
      address: practice.fetch(:location).fetch(:address),
      postcode: practice.fetch(:location).fetch(:postcode),
    }

    {
      code: practice.fetch(:code),
      name: {
        value: practice.fetch(:name),
        matches: [],
      },
      address: {
        value: address,
        matches: substring_indices(address, outcode),
      },
      practitioners: [],
      score: {},
    }
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
