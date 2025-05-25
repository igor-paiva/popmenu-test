require "test_helper"

class MenuItemTest < ActiveSupport::TestCase
  test "should create menu item" do
    menu = Menu.create!(name: "Test Menu", description: "Test Description")

    menu_item = MenuItem.create!(
      name: "Test Pizza",
      description: "Delicious test pizza",
      price: 12.99,
      picture_url: "https://www.coisasdaroca.com/wp-content/uploads/2023/01/Origem-da-pizza.png",
      menu:
    )

    assert_equal(
      menu, menu_item.menu,
      "Should return the menu through menu item"
    )
  end

  test "should validate uniqueness of name within menu" do
    menu = Menu.create!(name: "Test Menu", description: "Test Description")

    _menu_item = MenuItem.create!(
      name: "Test Pizza",
      description: "Delicious test pizza",
      price: 12.99,
      menu:
    )

    menu_item_same_name = MenuItem.new(
      name: "Test Pizza",
      description: "Delicious pizza",
      price: 13.99,
      menu:
    )

    assert_not menu_item_same_name.save

    assert_equal [ "Name has already been taken" ], menu_item_same_name.errors.to_a

    error = assert_raises(ActiveRecord::RecordInvalid, "Should validate uniqueness on database") do
      menu_item_same_name.save!
    end

    assert_equal "Validation failed: Name has already been taken", error.message

    menu_item_another_menu = MenuItem.new(
      name: "Test Pizza",
      description: "Delicious pizza",
      price: 13.99,
      menu: menus(:one)
    )

    assert menu_item_another_menu.save
  end
end
