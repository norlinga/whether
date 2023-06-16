# frozen_string_literal: true

require 'test_helper'

class TestWeatherByGeoService < ActiveSupport::TestCase
  def args
    { zip: '99999', lat: 48.36, lon: -116.56 }
  end

  test '.new succeeds when given the required arguments' do
    assert WeatherByGeo.new(**args)
  end

  test '.new fails when not given the required arguments' do
    assert_raises(ArgumentError) { WeatherByGeo.new(zip: '12345') }
  end

  test 'an instance of WeatherByGeo responds to .call' do
    w = WeatherByGeo.new(**args)
    assert w.respond_to?(:call)
  end

  test 'calling .fetch_weather_report pulls a weather report' do
    w = WeatherByGeo.new(**args)
    res = VCR.use_cassette('open_weather_api/report') { w.send(:fetch_weather_report) }
    assert_equal 48.36, res['lat']
    assert res.key?('current')
  end

  # because of how JSON dumping / marshalling works, note thatkeys transform from symbols to keys
  test 'calling .check_for_cached_weather_report for an existing cache returns the value of the cache' do
    w = WeatherByGeo.new(**args)
    w.cache_key = 'test'
    REDIS.set(w.cache_key, JSON.dump({ value: 'test value' }))
    assert_equal w.send(:check_for_cached_weather_report), { 'value' => 'test value' }
    REDIS.del(w.cache_key)
  end

  test 'calling .check_for_cached_weather_report for a non-existant cache returns nil' do
    w = WeatherByGeo.new(**args)
    w.cache_key = 'bogus'
    assert_nil w.send(:check_for_cached_weather_report)
  end
end
