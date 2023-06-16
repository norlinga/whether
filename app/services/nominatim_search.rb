# frozen_string_literal: true

# use Nominatim as the lookup backend for a Geocoder search
class NominatimSearch
  attr_reader :response

  def initialize(address)
    @address = address
    @zip = nil
    extract_zip
    @search_result = search
    @response = []
    normalize_search_result
  end

  def self.call(address)
    nominatim = new(address)
    nominatim.response
  end

  protected

  def extract_zip
    @zip = @address[/\b(\d{5})(?:-\d{4})?\b/, 1]
  end

  def search
    Geocoder.search(
      @address,
      lookup: :nominatim
    )
  end

  def normalize_search_result
    return if @search_result&.empty?

    @response = if @search_result.count == 1
                  format_results(@search_result.first.data)
                else
                  @search_result.map { |r| format_results(r.data) }.select { |r| r if r[:zip] }
                end
  end

  def format_results(addr)
    {
      zip: addr['address']['postcode'] || @zip,
      name: addr['display_name'] || "#{addr['address']['town']}, #{addr['address']['state']}",
      lat: addr['lat'],
      lon: addr['lon']
    }
  end
end
