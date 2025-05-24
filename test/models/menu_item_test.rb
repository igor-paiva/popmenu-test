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
end
