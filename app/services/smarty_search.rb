# frozen_string_literal: true

# use Smarty (SmartyStreets) as the lookup backend for Geocorder search
# normalizes return data as:
# { zip:, name:, lat:, lon: }
class SmartySearch
  attr_reader :response

  def initialize(address)
    @address = address
    @search_result = search
    @response = []
    normalize_search_result
  end

  def self.call(address)
    smarty = new(address)
    smarty.response
  end

  protected

  def search
    Geocoder.search(
      @address,
      lookup: :smarty_streets
    )
  end

  def normalize_search_result
    return if @search_result&.empty?

    addr = @search_result&.first&.data
    if addr['city_states']
      @response = format_for_zip_code_result(addr)
    elsif addr['components']
      @response = format_for_exact_address_result(addr)
    end
  end

  # specific to smarty - a match to a zipcode has the data we need but in a different
  # format than a match to an address, so we break out the formatting options
  def format_for_zip_code_result(addr)
    {
      zip: addr['zipcodes'].first['zipcode'],
      name: "#{addr['city_states'].first['city']}, #{addr['city_states'].first['state']}",
      lat: addr['zipcodes'].first['latitude'].to_s,
      lon: addr['zipcodes'].first['longitude'].to_s
    }
  end

  def format_for_exact_address_result(addr)
    {
      zip: addr['components']['zipcode'],
      name: "#{addr['components']['city_name']}, #{addr['components']['state_abbreviation']}",
      lat: addr['metadata']['latitude'].to_s,
      lon: addr['metadata']['longitude'].to_s
    }
  end
end
