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

      def extract_restaurants!
        @restaurants_data = @params[:restaurants]

        upsert_model_data!(model: Restaurant, model_namespace: :restaurants)
      end

      def extract_menus!
        @menus_data = @restaurants_data.flat_map do |restaurant|
          restaurant[:menus].map do |menu|
            menu_data = menu.slice(*(menus_update_fields + %i[menu_items]))

            menu_data[:menu_items] = menu[:dishes] if menu_data[:menu_items].blank? && menu.key?(:dishes)

            menu_data.merge(restaurant_id: @restaurants_map[restaurant.fetch_values(*restaurants_unique_by)])
          end
        end

        upsert_model_data!(model: Menu, model_namespace: :menus)
      end

      def extract_menu_items!
        @menu_items_data = @menus_data.flat_map do |menu|
          menu[:menu_items].map do |menu_item|
            menu_item.slice(*menu_items_update_fields).merge(
              menu_id: @menus_map[menu.fetch_values(*menus_unique_by)]
            )
          end
        end

        upsert_model_data!(model: MenuItem, model_namespace: :menu_items)
      end

      def extract_menu_menu_items!
        @menu_menu_items_data = @menu_items_data.map do |menu_item|
          {
            price: menu_item[:price],
            menu_id: menu_item[:menu_id],
            menu_item_id: @menu_items_map[menu_item.fetch_values(*menu_items_unique_by)]
          }
        end

        upsert_model_data!(model: MenuMenuItem, model_namespace: :menu_menu_items)
      end

      def upsert_model_data!(model:, model_namespace:)
        unique_by = send("#{model_namespace}_unique_by")
        returning = unique_by + %i[id]
        update_fields = send("#{model_namespace}_update_fields")

        model_data = instance_variable_get("@#{model_namespace}_data")

        result = model.upsert_all(model_data.map { _1.slice(*update_fields) }, unique_by:, returning:).to_a

        raise ActiveRecord::Rollback if result.length != model_data.length

        hash_map = result.map { [ _1.fetch_values(*unique_by.map(&:to_s)), _1["id"] ] }

        instance_variable_set("@#{model_namespace}_map", hash_map.to_h)
      end
  end
end
