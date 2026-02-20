namespace :powder do
  desc "Check powder forecasts and notify users if conditions improved from 0"
  task check: :environment do
    puts "Starting daily powder check at #{Time.current}..."

    SkiResort.all.each do |resort|
      service = OpenMeteoService.new(resort)
      forecast = service.fetch_forecast
      
      next unless forecast && forecast['daily']
      
      time_array = forecast['daily']['time']
      snowfall_array = forecast['daily']['snowfall_sum']
      max_temp_array = forecast['daily']['temperature_2m_max']
      
      # Determine if there's a powder day in the 14-day window
      next_powder_day = nil
      current_powder_index = 0

      # Check for today/tomorrow first
      today_snow = snowfall_array[0] || 0
      today_max_temp = max_temp_array[0] || 0
      today_penalty = today_max_temp > 0 ? (today_max_temp * 2) : 0
      today_index_val = today_snow - today_penalty
      today_powder_index = today_index_val > 0 ? [(today_index_val * 2).round, 100].min : 0

      # Check for next powder day in the 14-day window
      # This mimics the controller's logic - find the FIRST day >= 1
      time_array.each_with_index do |date_str, idx|
        d_snow = snowfall_array[idx] || 0
        d_max = max_temp_array[idx] || 0
        d_pen = d_max > 0 ? (d_max * 2) : 0
        d_idx = d_snow - d_pen
        d_pow = d_idx > 0 ? [(d_idx * 2).round, 100].min : 0
        
        if d_pow > 0
          date_obj = Date.parse(date_str)
          next_powder_day = {
            date: "#{date_obj.month}月#{date_obj.day}日",
            index: d_pow
          }
          current_powder_index = d_pow
          break
        end
      end

      resort_display_name = resort.name_ja.presence || resort.name_en
      puts "Resort: #{resort_display_name} | Current Index: #{current_powder_index} | Last Index: #{resort.last_powder_index}"

      # Condition to notify: Today index is > 0 AND Yesterday index was <= 0
      # OR: There's an active valid notification window
      last_val = resort.last_powder_index || 0
      if current_powder_index > 0 && last_val <= 0
        puts " -> Positive powder change detected! Sending emails."
        User.find_each do |user|
          PowderNotifierMailer.powder_alert(user, resort, next_powder_day[:date], current_powder_index).deliver_now
        end
      else
        puts " -> No email condition met."
      end

      # ALWAYS persist today's evaluation into the DB for tomorrow's verification
      # Also cache today's powder index for fast map loading
      resort.update!(last_powder_index: current_powder_index, cached_powder_index: today_powder_index)
    end
    
    puts "Finished powder check."
  end
end
