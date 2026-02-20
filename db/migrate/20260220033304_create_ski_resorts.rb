class CreateSkiResorts < ActiveRecord::Migration[8.1]
  def change
    create_table :ski_resorts do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.float :elevation

      t.timestamps
    end
  end
end
