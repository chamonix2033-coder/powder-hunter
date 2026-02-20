class ResortsController < ApplicationController
  def index
    if user_signed_in?
      @resorts = current_user.ski_resorts.order(name_ja: :asc)
    else
      @resorts = SkiResort.all.order(name_ja: :asc)
    end
    
    forecasts = OpenMeteoService.fetch_all_forecasts(@resorts) || {}
    
    @api_data = @resorts.map do |resort|
      forecast = forecasts[resort.id]
      
      powder_index = 0
      next_24h_snow = 0
      temperature = nil
      next_powder_day = nil
      
      if forecast && forecast['daily']
        time_array = forecast['daily']['time']
        snowfall_array = forecast['daily']['snowfall_sum']
        max_temp_array = forecast['daily']['temperature_2m_max']
        min_temp_array = forecast['daily']['temperature_2m_min']
        
        # Use the first day (today/tomorrow) for the index
        next_24h_snow = snowfall_array[0] || 0
        max_temp = max_temp_array[0] || 0
        min_temp = min_temp_array[0] || 0
        temperature = "#{min_temp}°C / #{max_temp}°C"
        
        # Simple Powder Index formula: more snow is good, high temp is bad
        # Max temp > 0 penalty
        temp_penalty = max_temp > 0 ? (max_temp * 2) : 0
        
        index_val = next_24h_snow - temp_penalty
        powder_index = index_val > 0 ? [(index_val * 2).round, 100].min : 0

        # Find the next powder day
        time_array.each_with_index do |date_str, idx|
          d_snow = snowfall_array[idx] || 0
          d_max = max_temp_array[idx] || 0
          d_pen = d_max > 0 ? (d_max * 2) : 0
          d_idx = d_snow - d_pen
          d_pow = d_idx > 0 ? [(d_idx * 2).round, 100].min : 0
          
          if d_pow > 0
            # format date as M月D日
            date_obj = Date.parse(date_str)
            next_powder_day = {
              date: "#{date_obj.month}月#{date_obj.day}日",
              index: d_pow
            }
            break
          end
        end
      end
      
      {
        resort: resort,
        powder_index: powder_index,
        next_24h_snow: next_24h_snow,
        temperature: temperature || "N/A",
        next_powder_day: next_powder_day
      }
    end
    
    # Sort by highest powder index
    @api_data.sort_by! { |data| -data[:powder_index] }
  end

  def show
    @resort = SkiResort.find(params[:id])
    forecasts = OpenMeteoService.fetch_all_forecasts([@resort]) || {}
    forecast = forecasts[@resort.id]
    
    @daily_forecasts = []
    
    if forecast && forecast['daily']
      time_array = forecast['daily']['time']
      snowfall_array = forecast['daily']['snowfall_sum']
      max_temp_array = forecast['daily']['temperature_2m_max']
      min_temp_array = forecast['daily']['temperature_2m_min']
      
      time_array.each_with_index do |date_str, index|
        snowfall = snowfall_array[index] || 0
        max_temp = max_temp_array[index] || 0
        min_temp = min_temp_array[index] || 0
        
        # Simple Powder Index for the specific day
        temp_penalty = max_temp > 0 ? (max_temp * 2) : 0
        index_val = snowfall - temp_penalty
        powder_index = index_val > 0 ? [(index_val * 2).round, 100].min : 0
        
        weather_emoji = powder_index > 50 ? '🏔️' : (snowfall > 0 ? '❄️' : (max_temp > 5 ? '☀️' : '⛄️'))
        
        @daily_forecasts << {
          date: date_str,
          weather: "#{weather_emoji} #{snowfall} cm",
          min_temp: min_temp,
          max_temp: max_temp,
          powder_index: powder_index
        }
      end
    end
  end
end
