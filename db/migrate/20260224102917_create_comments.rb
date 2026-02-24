class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ski_resort, null: false, foreign_key: true
      t.string :body, null: false
      t.string :url

      t.timestamps
    end
  end
end
