class CreateSelections < ActiveRecord::Migration[8.1]
  def change
    create_table :selections do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ski_resort, null: false, foreign_key: true

      t.timestamps
    end
  end
end
