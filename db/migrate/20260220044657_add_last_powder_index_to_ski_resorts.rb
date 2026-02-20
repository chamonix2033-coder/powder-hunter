class AddLastPowderIndexToSkiResorts < ActiveRecord::Migration[8.1]
  def change
    add_column :ski_resorts, :last_powder_index, :integer
  end
end
