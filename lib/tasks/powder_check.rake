namespace :powder do
  desc "Check powder forecasts and notify users if conditions changed"
  task check: :environment do
    puts "Starting daily powder check at #{Time.current}..."

    notify_resorts_data = []

    all_resorts = SkiResort.all
    forecasts = OpenMeteoService.fetch_all_forecasts(all_resorts) || {}

    all_resorts.each do |resort|
      forecast = forecasts[resort.id]

      next unless forecast && forecast["daily"]

      time_array = forecast["daily"]["time"]
      snowfall_array = forecast["daily"]["snowfall_sum"]
      max_temp_array = forecast["daily"]["temperature_2m_max"]

      # Determine if there's a powder day in the 14-day window
      next_powder_day = nil
      current_powder_index = 0
      current_powder_date = nil

      # Check for today/tomorrow first
      today_snow = snowfall_array[0] || 0
      today_max_temp = max_temp_array[0] || 0
      today_penalty = today_max_temp > 0 ? (today_max_temp * 2) : 0
      today_index_val = today_snow - today_penalty
      today_powder_index = today_index_val > 0 ? [ (today_index_val * 2).round, 100 ].min : 0

      # Check for next powder day in the 14-day window
      time_array.each_with_index do |date_str, idx|
        d_snow = snowfall_array[idx] || 0
        d_max = max_temp_array[idx] || 0
        d_pen = d_max > 0 ? (d_max * 2) : 0
        d_idx = d_snow - d_pen
        d_pow = d_idx > 0 ? [ (d_idx * 2).round, 100 ].min : 0

        if d_pow > 0
          date_obj = Date.parse(date_str)
          next_powder_day = {
            date: "#{date_obj.month}月#{date_obj.day}日",
            index: d_pow
          }
          current_powder_index = d_pow
          current_powder_date = date_obj
          break
        end
      end

      resort_display_name = resort.name_ja.presence || resort.name_en
      last_val = resort.last_powder_index || 0
      last_date = resort.last_powder_date

      puts "Resort: #{resort_display_name} | Current Index: #{current_powder_index} (#{current_powder_date}) | Last Index: #{last_val} (#{last_date})"

      # Determine notification reason
      reason = nil
      if current_powder_index > 0 && last_val <= 0
        # New powder chance (was 0, now > 0)
        reason = :new
      elsif current_powder_index > 0 && last_val > 0 && current_powder_date && last_date
        if current_powder_date < last_date
          reason = :earlier
        elsif current_powder_date > last_date
          reason = :later
        end
      end

      if reason
        notify_resorts_data << {
          resort: resort,
          date: next_powder_day[:date],
          index: current_powder_index,
          reason: reason,
          last_date_str: last_date ? "#{last_date.month}月#{last_date.day}日" : nil
        }
        puts "  -> Notification reason: #{reason}"
      end

      # ALWAYS persist today's evaluation into the DB for tomorrow's verification
      resort.update!(
        last_powder_index: current_powder_index,
        cached_powder_index: today_powder_index,
        last_powder_date: current_powder_date
      )
    end

    # Process Grouped Emails
    if notify_resorts_data.any?
      puts "Processing email deliveries for users..."
      User.find_each do |user|
        user_resort_ids = user.ski_resorts.pluck(:id)
        matching_data = notify_resorts_data.select do |data|
          user_resort_ids.include?(data[:resort].id)
        end

        if matching_data.any?
          puts " -> Sending alert to #{user.email} for #{matching_data.size} matched resorts."
          begin
            PowderNotifierMailer.powder_alert(user, matching_data).deliver_now
            puts "    ✅ Email sent successfully to #{user.email}"
          rescue => e
            puts "    ❌ Email delivery FAILED for #{user.email}: #{e.class} - #{e.message}"
          end
        end
      end
    else
      puts "No powder condition changes to notify about today."
    end

    puts "Finished powder check."
  end
end
