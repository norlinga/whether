# frozen_string_literal: true

# tries to return a cached weather report by zip if one is available
# otherwise retireves a weather report by lat and lon, serializes,
# and stores a weather report before returning it
class WeatherByGeo
  WEATHER_REPORT_CACHE_KEY_PREFIX = 'weather_report_for_'
  WEATHER_REPORT_CACHE_KEY_TTL = 1800

  attr_accessor :cache_key, :serialized_weather_report

  def initialize(zip:, lat:, lon:)
    @zip = zip
    @cache_key = "#{WEATHER_REPORT_CACHE_KEY_PREFIX}#{@zip}"
    @cached_weather_report = check_for_cached_weather_report
    @lat = lat
    @lon = lon
    @weather_report = nil
    @serialized_weather_report = nil
  end

  def call
    return @cached_weather_report if @cached_weather_report

    @weather_report = fetch_weather_report
    @serialized_weather_report = serialize_weather_report
    cache_weather_report
    @serialized_weather_report
  end

  private

  def check_for_cached_weather_report
    stored_data = REDIS.get(@cache_key)
    stored_data ? JSON.parse(stored_data) : nil
  end

  def cache_weather_report
    REDIS.set(@cache_key, JSON.dump(@serialized_weather_report))
    REDIS.expire(@cache_key, WEATHER_REPORT_CACHE_KEY_TTL)
  end

  def fetch_weather_report
    JSON.parse(
      Faraday.get(
        "https://api.openweathermap.org/data/3.0/onecall?lat=#{@lat}&lon=#{@lon}&appid=#{ENV.fetch(
          'OPEN_WEATHER_API_KEY', nil
        )}&units=imperial&exclude=minutely,hourly"
      ).body
    )
  end

  def serialize_weather_report
    OpenWeatherMapFormatter.call(@weather_report)
  end
end
