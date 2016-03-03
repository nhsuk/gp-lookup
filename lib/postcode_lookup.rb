class PostcodeLookup
  def initialize(http_client:)
    @http_client = http_client
  end

  def find(code)
    response = find_postcode(code)
    return Postcode.new(response.body.fetch("result")) if response.success?

    response = find_outcode(code)
    return Outcode.new(response.body.fetch("result")) if response.success?

    NullPostcode.new
  end

private
  attr_reader :http_client

  def find_postcode(code)
    endpoint = "/postcodes/%{code}" % {
      code: code.gsub(/\s/, "")
    }

    http_client.get(endpoint)
  end

  def find_outcode(code)
    endpoint = "/outcodes/%{code}" % {
      code: code.lstrip.split(/\s/).first
    }

    http_client.get(endpoint)
  end

  class NullPostcode
    def postcode?
      false
    end

    def outcode?
      false
    end
  end

  class Postcode < NullPostcode
    def initialize(data)
      @data = data
    end

    def postcode?
      true
    end

    def postcode
      data.fetch("postcode")
    end

    def latitude
      data.fetch("latitude")
    end

    def longitude
      data.fetch("longitude")
    end

  private
    attr_reader :data
  end

  class Outcode < NullPostcode
    def initialize(data)
      @data = data
    end

    def outcode?
      true
    end

    def outcode
      data.fetch("outcode")
    end

  private
    attr_reader :data
  end
end
