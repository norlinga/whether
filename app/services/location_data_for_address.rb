# frozen_string_literal: true

# this service can return three results to the caller.
# 1. given an address search that returns a single result, a hash containing a zip, name, lat, and long
# 2, given an address search that returns multiple results, an array of hashes with zip and description
# 3, given an address search that returns no matches, an empty array
# this service expects a single address string and will arbitrate calls to other
# services.
class LocationDataForAddress
  ADDRESS_SEARCH_SERVICES = [SmartySearch, NominatimSearch].freeze

  attr_accessor :locations

  def initialize(address)
    @address = address
    @locations = query_address_search_services
  end

  def self.call(address)
    location_data = new(address)
    location_data.locations
  end

  protected

  def query_address_search_services
    all_results = []

    ADDRESS_SEARCH_SERVICES.each do |klass|
      service_result = klass.call(@address)
      all_results << service_result
    end

    all_results.flatten!

    return [] if all_results.empty?
    return all_results.first if all_results.count == 1 || all_results.first[:zip] == @address
    return all_results if all_results.any?
  end
end
