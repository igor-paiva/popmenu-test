class ChangeMenuAndMenuItemAssociationCardinality < ActiveRecord::Migration[8.0]
  def up
    MenuItem.select(:id, :menu_id).where.not(menu_id: nil).find_each do |menu_item|
      MenuMenuItem.create!(menu_id: menu_item.menu_id, menu_item_id: menu_item.id)
    end

    remove_foreign_key :menu_items, :menus
    remove_column :menu_items, :menu_id
  end

  def down
    add_column :menu_items, :menu_id, :bigint, null: true
    add_foreign_key :menu_items, :menus

    menu_menu_items = MenuMenuItem.select(:id, :menu_id, :menu_item_id)

    menu_menu_items.find_each do |menu_menu_item|
      menu_item = MenuItem.find_by(id: menu_menu_item.menu_item_id)

      menu_item&.update!(menu_id: menu_menu_item.menu_id)
    end

    menu_menu_items.in_batches.delete_all
  end
end
