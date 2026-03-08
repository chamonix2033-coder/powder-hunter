class CreateWeatherCaches < ActiveRecord::Migration[8.1]
  def change
    create_table :weather_caches do |t|
      t.references :ski_resort, null: false, foreign_key: true
      t.json :forecast_data
      t.datetime :last_fetched_at

      t.timestamps
    end
  end
end
