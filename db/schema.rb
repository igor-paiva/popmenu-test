# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_29_234638) do
  create_table "menu_items", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "picture_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price"
    t.index ["name"], name: "index_menu_items_on_name", unique: true
  end

  create_table "menu_menu_items", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.integer "menu_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price"
    t.index ["menu_id", "menu_item_id"], name: "index_menu_menu_items_on_menu_id_and_menu_item_id", unique: true
    t.index ["menu_id"], name: "index_menu_menu_items_on_menu_id"
    t.index ["menu_item_id"], name: "index_menu_menu_items_on_menu_item_id"
  end

  create_table "menus", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "restaurant_id"
    t.index ["name", "restaurant_id"], name: "index_menus_on_name_and_restaurant_id", unique: true
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_menu_id"
    t.index ["current_menu_id"], name: "index_restaurants_on_current_menu_id"
    t.index ["name"], name: "index_restaurants_on_name", unique: true
  end

  add_foreign_key "menu_menu_items", "menu_items"
  add_foreign_key "menu_menu_items", "menus"
  add_foreign_key "menus", "restaurants", on_delete: :nullify
  add_foreign_key "restaurants", "menus", column: "current_menu_id"
end
