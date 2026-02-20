class AddCachedPowderIndexToSkiResorts < ActiveRecord::Migration[8.1]
  def change
    add_column :ski_resorts, :cached_powder_index, :integer
  end
end
