module Services
  class ImportRestaurants
    def initialize(params)
      @params = params.to_h
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

        unique_by = Array.wrap(restaurants_unique_by)
        returning = unique_by + %i[id]

        result = Restaurant.upsert_all(
          @restaurants_data.map { _1.slice(*restaurants_update_fields) }, unique_by:, returning:
        ).to_a

        raise ActiveRecord::Rollback if result.length != @restaurants_data.length

        hash_map = result.map { [ _1.fetch_values(*unique_by.map(&:to_s)), _1["id"] ] }

        @restaurants_map = hash_map.to_h
      end

      def extract_menus!
        @menus_data = @restaurants_data.flat_map do |restaurant|
          restaurant[:menus].map do |menu|
            menu_data = menu.slice(*%i[name description menu_items])

            menu_data[:menu_items] = menu[:dishes] if menu_data[:menu_items].blank? && menu.key?(:dishes)

            menu_data.merge(restaurant_id: @restaurants_map[restaurant.fetch_values(*restaurants_unique_by)])
          end
        end

        unique_by = Array.wrap(menus_unique_by)
        returning = unique_by + %i[id]

        result = Menu.upsert_all(
          @menus_data.map { _1.slice(*menus_update_fields) }, unique_by:, returning:
        ).to_a

        raise ActiveRecord::Rollback if result.length != @menus_data.length

        hash_map = result.map { [ _1.fetch_values(*unique_by.map(&:to_s)), _1["id"] ] }

        @menus_map = hash_map.to_h
      end

      def extract_menu_items!
        @menu_items_data = @menus_data.flat_map do |menu|
          menu[:menu_items].map do |menu_item|
            menu_item.slice(*%i[name description price]).merge(
              menu_id: @menus_map[menu.fetch_values(*menus_unique_by)]
            )
          end
        end

        unique_by = Array.wrap(menu_items_unique_by)
        returning = unique_by + %i[id]

        result = MenuItem.upsert_all(
          @menu_items_data.map { _1.slice(*menu_items_update_fields) }, unique_by:, returning:
        ).to_a

        raise ActiveRecord::Rollback if result.length != @menu_items_data.length

        hash_map = result.map { [ _1.fetch_values(*unique_by.map(&:to_s)), _1["id"] ] }

        @menu_items_map = hash_map.to_h
      end

      def extract_menu_menu_items!
        @menu_menu_items_data = @menu_items_data.map do |menu_item|
          {
            menu_id: menu_item[:menu_id],
            menu_item_id: @menu_items_map[menu_item.fetch_values(*menu_items_unique_by)],
            price: menu_item[:price]
          }
        end

        result = MenuMenuItem.upsert_all(
          @menu_menu_items_data.map { _1.slice(*menu_menu_items_update_fields) },
          unique_by: menu_menu_items_unique_by,
          returning: :id
        )

        raise ActiveRecord::Rollback if result.length != @menu_menu_items_data.length
      end

      def restaurants_unique_by
        %i[name]
      end

      def restaurants_update_fields
        %i[name]
      end

      def menus_unique_by
        %i[name restaurant_id]
      end

      def menus_update_fields
        %i[name description restaurant_id]
      end

      def menu_items_unique_by
        %i[name]
      end

      def menu_items_update_fields
        %i[name description price picture_url]
      end

      def menu_menu_items_unique_by
        %i[menu_id menu_item_id]
      end

      def menu_menu_items_update_fields
        %i[menu_id menu_item_id price]
      end
  end
end
