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
    return { forecasts: {}, stale: false } if resorts.empty?

    forecasts_by_id = {}
    missing_resorts = []

    # 1. 既存の個別キャッシュ(DB)をチェック
    resorts.each do |resort|
      cache = WeatherCache.find_by(ski_resort_id: resort.id)

      # 12時間以内に取得したデータがあればキャッシュとして採用
      if cache && cache.last_fetched_at && cache.last_fetched_at > 12.hours.ago
        forecasts_by_id[resort.id] = cache.forecast_data
      else
        missing_resorts << resort
      end
    end

    # 全てキャッシュにあれば終了
    return { forecasts: forecasts_by_id, stale: false } if missing_resorts.empty?

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

    stale = false

    begin
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        parsed = JSON.parse(response.body)
        results_array = parsed.is_a?(Array) ? parsed : [ parsed ]

        # 3. 取得した結果をDBにキャッシュ保存 (12時間有効となるようlast_fetched_atを更新)
        missing_resorts.each_with_index do |resort, index|
          data = results_array[index]
          if data
            cache = WeatherCache.find_or_initialize_by(ski_resort_id: resort.id)
            cache.update!(
              forecast_data: data,
              last_fetched_at: Time.current
            )
            forecasts_by_id[resort.id] = data
          end
        end
      else
        # APIエラー（429レート制限等）: キャッシュ分で代替
        Rails.logger.warn("OpenMeteo API error! Code: #{response.code}, URI: #{uri}")
        Rails.logger.warn("Response body: #{response.body}")
        stale = true
      end
    rescue StandardError => e
      Rails.logger.error("Critical error fetching OpenMeteo data: #{e.class} - #{e.message}")
      Rails.logger.error("URI attempted: #{uri}")
      stale = true
    end

    { forecasts: forecasts_by_id, stale: stale }
  end
end
