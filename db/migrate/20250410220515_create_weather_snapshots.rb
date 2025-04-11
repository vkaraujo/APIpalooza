class CreateWeatherSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :weather_snapshots do |t|
      t.string :city
      t.float :temperature
      t.string :condition
      t.datetime :fetched_at

      t.timestamps
    end
  end
end
