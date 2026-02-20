class UpdateSkiResortsSchema < ActiveRecord::Migration[8.1]
  def change
    rename_column :ski_resorts, :name, :name_en
    rename_column :ski_resorts, :elevation, :elevation_base
    add_column :ski_resorts, :name_ja, :string
    add_column :ski_resorts, :elevation_top, :float
  end
end
