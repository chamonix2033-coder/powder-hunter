require "net/http"
require "json"

class OpenMeteoService
  BASE_URL = "https://api.open-meteo.com/v1/forecast".freeze

  def initialize(ski_resort)
    @ski_resort = ski_resort
  end

  def fetch_forecast
    # Delegate to the batch method for backward compatibility
    forecasts = self.class.fetch_all_forecasts([ @ski_resort ])
    forecasts ? forecasts[@ski_resort.id] : nil
  end

  def self.fetch_all_forecasts(resorts)
    return {} if resorts.empty?

    # Create a unique cache key based on the specific combination of requested resorts
    cache_key = "open_meteo_forecast_all_v3_#{resorts.map(&:id).sort.join('-')}"

    Rails.cache.fetch(cache_key, expires_in: 3.hours, skip_nil: true) do
      uri = URI(BASE_URL)
      params = {
        latitude: resorts.map(&:latitude).join(","),
        longitude: resorts.map(&:longitude).join(","),
        elevation: resorts.map(&:elevation_base).join(","),
        hourly: "temperature_2m,snowfall",
        daily: "snowfall_sum,temperature_2m_max,temperature_2m_min",
        timezone: "auto",
        forecast_days: 14
      }

      uri.query = URI.encode_www_form(params)

      begin
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          parsed = JSON.parse(response.body)
          # Open-Meteo returns an Array if multiple locations, but a Hash if only 1 location
          results_array = parsed.is_a?(Array) ? parsed : [parsed]

          # Map the response objects back to the resort IDs in the same order
          forecasts_by_resort_id = {}
          resorts.each_with_index do |resort, index|
            forecasts_by_resort_id[resort.id] = results_array[index]
          end
          forecasts_by_resort_id
        else
          Rails.logger.error("OpenMeteo API error: #{response.code} - #{response.body}")
          nil
        end
      rescue StandardError => e
        Rails.logger.error("Error fetching batch OpenMeteo data: #{e.message}")
        nil
      end
    end
  end
end
