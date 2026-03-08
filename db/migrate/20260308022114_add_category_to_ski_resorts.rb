class AddCategoryToSkiResorts < ActiveRecord::Migration[8.1]
  def change
    add_column :ski_resorts, :category, :integer, default: 0
  end
end
