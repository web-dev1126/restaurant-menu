class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.references :menu, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 8, scale: 2, null: false
      t.string :category, null: false
      t.boolean :available, default: true, null: false

      t.timestamps
    end

    add_index :menu_items, [:menu_id, :name], unique: true
    add_index :menu_items, :category
  end
end 