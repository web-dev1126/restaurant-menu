class CreateMenuItemMenus < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_item_menus do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :menu, null: false, foreign_key: true

      t.timestamps
    end

    add_index :menu_item_menus, [:menu_item_id, :menu_id], unique: true
  end
end 