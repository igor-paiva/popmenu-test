class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.string :name
      t.string :description
      t.float :price
      # In a real production app, we should probably use active storage
      t.string :picture_url
      t.belongs_to :menu

      t.timestamps
    end
  end
end
