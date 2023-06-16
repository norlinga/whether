# frozen_string_literal: true

# we offer the 'choose' method in the case that the returns
# from address lookup are ambiguous.  We present all the results
# to the user who will click into the result they want, or search again
class ForecastController < ApplicationController
  def index; end

  def show
    flash.clear
    @address = LocationDataForAddress.call(params[:id])
    @weather_report = WeatherByGeo.new(zip: @address[:zip], lat: @address[:lat], lon: @address[:lon]).call
  end
end
