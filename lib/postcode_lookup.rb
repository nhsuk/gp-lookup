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
    postcode = code.gsub(/\s/, "")
    return NullResponse.new unless postcodeish?(postcode)

    http_client.get("/postcodes/#{postcode}")
  end

  def find_outcode(code)
    outcode = code.lstrip.split(/\s/).first
    return NullResponse.new unless outcodeish?(outcode)

    http_client.get("/outcodes/#{outcode}")
  end

  def postcodeish?(code)
    code =~ /^[a-z]{1,2}[0-9]{1,2}[a-z]?[0-9][a-z]{2}$/i
  end

  def outcodeish?(code)
    code =~ /^[a-z]{1,2}[0-9]{1,2}[a-z]?$/i
  end

  class NullResponse
    def success?
      false
    end
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
