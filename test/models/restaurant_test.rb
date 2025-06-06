require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  test "should create menu with multiple menu items" do
    restaurant = Restaurant.create!(
      name: "Test Restaurant",
      menus_attributes: [
        { name: "Test Menu", description: "Test Description" }
      ]
    )

    MenuItem.create!(
      name: "Test Bread",
      description: "Delicious test bread",
      price: 3.99,
      menu_menu_items_attributes: [ { menu_id: restaurant.menus.first.id, price: 4.99 } ]
    )

    assert_equal 1, restaurant.menus.count

    restaurant.menus.build(name: "Test Menu 2", description: "Delicious test menu 2")

    restaurant.save!

    assert_equal 2, restaurant.menus.count
  end

  test "should NOT destroy menus when restaurant is destroyed" do
    restaurant = restaurants(:one)

    menu_one, menu_two = restaurant.menus

    assert_no_difference "Menu.count" do
      restaurant.destroy!
    end

    assert_nil Restaurant.find_by(id: restaurant.id)

    assert_nil menu_one.reload.restaurant_id
    assert_nil menu_two.reload.restaurant_id
  end

  test "should associate current menu with restaurant" do
    restaurant = Restaurant.create!(name: "Test Restaurant")

    menu_one = Menu.create!(name: "Test Menu", description: "Test Description", restaurant:)

    assert_nil restaurant.current_menu

    restaurant.update!(current_menu: menu_one)

    assert_equal menu_one, restaurant.current_menu
  end

  test "should require name to be present" do
    restaurant = Restaurant.new

    assert_not restaurant.valid?
    assert_includes restaurant.errors[:name], "can't be blank"
  end

  test "should require name to be unique" do
    existing_restaurant = restaurants(:one)
    duplicate_restaurant = Restaurant.new(name: existing_restaurant.name)

    assert_not duplicate_restaurant.valid?
    assert_includes duplicate_restaurant.errors[:name], "has already been taken"
  end

  test "should allow different restaurant names" do
    Restaurant.create!(name: "Restaurant One")
    restaurant_two = Restaurant.new(name: "Restaurant Two")

    assert restaurant_two.valid?
  end
end
