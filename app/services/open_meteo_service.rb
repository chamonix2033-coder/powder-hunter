require 'net/http'
require 'json'

class OpenMeteoService
  BASE_URL = 'https://api.open-meteo.com/v1/forecast'.freeze

  def initialize(ski_resort)
    @ski_resort = ski_resort
  end

  def fetch_forecast
    cache_key = "open_meteo_forecast_#{@ski_resort.id}"

    Rails.cache.fetch(cache_key, expires_in: 3.hours, skip_nil: true) do
      uri = URI(BASE_URL)
      params = {
        latitude: @ski_resort.latitude,
        longitude: @ski_resort.longitude,
        elevation: @ski_resort.elevation_base,
        hourly: 'temperature_2m,snowfall',
        daily: 'snowfall_sum,temperature_2m_max,temperature_2m_min',
        timezone: 'auto',
        forecast_days: 14
      }
      
      uri.query = URI.encode_www_form(params)
      
      begin
        response = Net::HTTP.get_response(uri)
        
        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        else
          Rails.logger.error("OpenMeteo API error: #{response.code} - #{response.body}")
          nil
        end
      rescue StandardError => e
        Rails.logger.error("Error fetching OpenMeteo data: #{e.message}")
        nil
      end
    end
  end
end
