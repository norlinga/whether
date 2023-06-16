# frozen_string_literal: true

# serializing an object can be a lot - it is what it is
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
# Ignore RuboCop warnings for the entire file

# returns a formatted OpenWeatherMap report as a Ruby hash
# serializing anticipating conversion back and forth from JSON,
# use string keys instead of symbol keys
class OpenWeatherMapFormatter
  def self.call(report)
    today = report['daily'].shift
    {
      'current' => {
        'current_temp' => report['current']['temp'].to_i,
        'high' => today['temp']['max'].to_i,
        'low' => today['temp']['min'].to_i,
        'summary' => today['summary'],
        'reported_at' => report['current']['dt']
      },
      'daily' => report['daily'].map do |day|
        {
          'formatted_date_string' => Time.at(day['dt']).strftime('%A, %B %e'),
          'high' => day['temp']['max'].to_i,
          'low' => day['temp']['min'].to_i,
          'summary' => day['summary']
        }
      end
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # Re-enable RuboCop warnings for the rest of the file
end
