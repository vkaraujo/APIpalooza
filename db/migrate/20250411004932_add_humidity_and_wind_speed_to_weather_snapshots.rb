class AddHumidityAndWindSpeedToWeatherSnapshots < ActiveRecord::Migration[7.1]
  def change
    add_column :weather_snapshots, :humidity, :integer
    add_column :weather_snapshots, :wind_speed, :float
  end
end
