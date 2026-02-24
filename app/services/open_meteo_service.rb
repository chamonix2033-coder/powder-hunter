require "net/http"
require "json"

class OpenMeteoService
  BASE_URL = "https://api.open-meteo.com/v1/forecast".freeze

  def initialize(ski_resort)
    @ski_resort = ski_resort
  end

  def fetch_forecast
    # Use the batch method to benefit from caching logic
    forecasts = self.class.fetch_all_forecasts([ @ski_resort ])
    forecasts[@ski_resort.id]
  end

  def self.fetch_all_forecasts(resorts)
    return {} if resorts.empty?

    forecasts_by_id = {}
    missing_resorts = []

    # 1. 既存の個別キャッシュをチェック
    resorts.each do |resort|
      cache_key = "open_meteo_resort_v4_#{resort.id}"
      cached_data = Rails.cache.read(cache_key)

      if cached_data
        forecasts_by_id[resort.id] = cached_data
      else
        missing_resorts << resort
      end
    end

    # 全てキャッシュにあれば終了
    return forecasts_by_id if missing_resorts.empty?

    # 2. キャッシュにない分だけAPIリクエスト
    uri = URI(BASE_URL)
    params = {
      latitude: missing_resorts.map(&:latitude).join(","),
      longitude: missing_resorts.map(&:longitude).join(","),
      elevation: missing_resorts.map(&:elevation_base).join(","),
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
        results_array = parsed.is_a?(Array) ? parsed : [ parsed ]

        # 3. 取得した結果を個別にキャッシュ保存（12時間）
        missing_resorts.each_with_index do |resort, index|
          data = results_array[index]
          if data
            cache_key = "open_meteo_resort_v4_#{resort.id}"
            Rails.cache.write(cache_key, data, expires_in: 12.hours)
            forecasts_by_id[resort.id] = data
          end
        end
      else
        Rails.logger.error("OpenMeteo API error! Code: #{response.code}, URI: #{uri}")
        Rails.logger.error("Response body: #{response.body}")
        # APIエラー時は現在取得できている分（キャッシュ分）だけ返す
      end
    rescue StandardError => e
      Rails.logger.error("Critical error fetching OpenMeteo data: #{e.class} - #{e.message}")
      Rails.logger.error("URI attempted: #{uri}")
    end

    forecasts_by_id
  end
end
