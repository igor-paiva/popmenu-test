class CreateMenuMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_menu_items do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.timestamps
    end

    add_index :menu_menu_items, %i[menu_id menu_item_id], unique: true
  end
end
