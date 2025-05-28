module Services
  class ImportRestaurants
    def initialize(params)
      @params = params
    end

    def run
      process_data
    end

    private

      def process_data
        ActiveRecord::Base.transaction do
          extract_restaurants!
          extract_menus!
          extract_menu_items!
          extract_menu_menu_items!
        end
      end

      def extract_restaurants!
        @restaurants_data = @params[:restaurants]

        result = Restaurant.upsert_all(
          @restaurants_data.map { _1.slice(:name) }, unique_by: :name, returning: %i[name id]
        ).to_a

        raise ActiveRecord::Rollback if result.length != @restaurants_data.length

        @restaurants_map = result.map { [ _1["name"], _1["id"] ] }.to_h
      end

      def extract_menus!
        @menus_data = @restaurants_data.flat_map do |restaurant|
          restaurant[:menus].map do |menu|
            menu_data = menu.slice(*%i[name description menu_items])

            menu_data[:menu_items] = menu[:dishes] if menu_data[:menu_items].blank? && menu.key?(:dishes)

            menu_data.merge(restaurant_id: @restaurants_map[restaurant[:name]])
          end
        end

        result = Menu.upsert_all(
          @menus_data.map { _1.slice(*%i[name description restaurant_id]) },
          unique_by: %i[name restaurant_id],
          returning: %i[restaurant_id name id]
        ).to_a

        raise ActiveRecord::Rollback if result.length != @menus_data.length

        @menus_map = result.map { [ [ _1["restaurant_id"], _1["name"] ], _1["id"] ] }.to_h
      end

      def extract_menu_items!
        @menu_items_data = @menus_data.flat_map do |menu|
          menu[:menu_items].map do |menu_item|
            menu_item.slice(*%i[name description price]).merge(menu_id: @menus_map[[ menu[:restaurant_id], menu[:name] ]])
          end
        end

        result = MenuItem.upsert_all(
          @menu_items_data.map { _1.slice(*%i[name description price]) },
          unique_by: :name,
          returning: %i[name id]
        ).to_a

        raise ActiveRecord::Rollback if result.length != @menu_items_data.length

        @menu_items_map = result.map { [ _1["name"], _1["id"] ] }.to_h
      end

      def extract_menu_menu_items!
        menu_menu_items_data = @menu_items_data.map do |menu_item|
          {
            menu_id: menu_item[:menu_id],
            menu_item_id: @menu_items_map[menu_item[:name]],
            price: menu_item[:price]
          }
        end

        result = MenuMenuItem.upsert_all(
          menu_menu_items_data,
          unique_by: %i[menu_id menu_item_id],
          returning: :id
        )

        raise ActiveRecord::Rollback if result.length != menu_menu_items_data.length
      end
  end
end
