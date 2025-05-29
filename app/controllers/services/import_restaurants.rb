module Services
  class ImportRestaurants
    MODELS = %i[restaurants menus menu_items menu_menu_items].freeze

    def initialize(params)
      @result = {}
      @params = params.to_h
    end

    class << self
      def run(params)
        new(params).run
      end
    end

    def run
      initialize_result

      process_data

      fill_result

      @result
    end

    private

      def initialize_result
        @result[:general] = { message: nil, errors: [] }

        MODELS.each do |model|
          @result[model] = { success: [], errors: [] }
        end
      end

      def fill_result
        if @result[:general][:errors].empty?
          @result[:general][:success] = true
          @result[:general][:message] = "Restaurants imported successfully"
          return
        end

        @result[:general][:success] = false
        @result[:general][:message] = "Failed to import restaurants. All changes were rolled back."
      end

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

            menu_data.merge(restaurant_id: restaurants_record_id(restaurant))
          end
        end

        upsert_model_data!(model: Menu, model_namespace: :menus)
      end

      def extract_menu_items!
        @menu_items_data = @menus_data.flat_map do |menu|
          menu[:menu_items].map do |menu_item|
            menu_item.slice(*menu_items_update_fields).merge(menu_id: menus_record_id(menu))
          end
        end

        upsert_model_data!(model: MenuItem, model_namespace: :menu_items)
      end

      def extract_menu_menu_items!
        @menu_menu_items_data = @menu_items_data.map do |menu_item|
          {
            price: menu_item[:price],
            menu_id: menu_item[:menu_id],
            menu_item_id: menu_items_record_id(menu_item)
          }
        end

        upsert_model_data!(
          model: MenuMenuItem, model_namespace: :menu_menu_items,
          skip_ids_map: true, custom_message: "Failed to associate menu items with menus"
        )
      end

      def upsert_model_data!(model:, model_namespace:, skip_ids_map: false, custom_message: nil)
        unique_by = send("#{model_namespace}_unique_by")
        returning = unique_by + %i[id]
        update_fields = send("#{model_namespace}_update_fields")

        model_data = instance_variable_get("@#{model_namespace}_data")

        result = model
          .upsert_all(model_data.map { _1.slice(*update_fields) }, unique_by:, returning:)
          .to_a
          .map(&:symbolize_keys)

        if result.length != model_data.length
          @result[:general][:errors] << custom_message || "Failed to import #{model_namespace} records"

          raise ActiveRecord::Rollback
        end

        ids_map = result.map do |record_result|
          unique_by_values = send("#{model_namespace}_unique_by_values", record_result)

          [ unique_by_values, record_result[:id] ]
        end.to_h

        instance_variable_set("@#{model_namespace}_ids_map", ids_map) unless skip_ids_map

        log_successful_imports(model_namespace:, result:)

        log_failed_imports(model_namespace:, model_data:, ids_map:)
      end

      def log_successful_imports(model_namespace:, result:)
        @result[model_namespace][:success] = result
      end

      def log_failed_imports(model_namespace:, model_data:, ids_map:)
        unique_by = send("#{model_namespace}_unique_by")

        model_data.each do |record|
          unique_by_values_hash = record.slice(*unique_by)

          next if ids_map.key?(unique_by_values_hash.values)

          @result[model_namespace][:errors] << unique_by_values_hash.merge(description: "Failed to create or update record")
        end
      end

      MODELS.each do |model_namespace|
        define_method("#{model_namespace}_unique_by_values") do |record_hash|
          record_hash.fetch_values(*send("#{model_namespace}_unique_by"))
        end

        define_method("#{model_namespace}_record_id") do |record_hash|
          unique_by_values = send("#{model_namespace}_unique_by_values", record_hash)

          ids_map = instance_variable_get("@#{model_namespace}_ids_map")

          ids_map[unique_by_values]
        end
      end
  end
end
