# Service class for importing restaurant data with nested menus and menu items.
#
# This service handles the import of restaurants along with their associated menus,
# menu items, and menu-item associations. It performs upsert operations to create
# or update records, and maintains data integrity through database transactions.
#
# @example Usage
#   result = Services::ImportRestaurants.run(params)
#   if result.dig(:general, :success)
#     puts "Import successful: #{result.dig(:general, :message)}"
#   else
#     puts "Import failed: #{result.dig(:general, :errors)}"
#   end
#
# @param params [Hash] The import parameters containing restaurant data
#
# Expected params structure:
#   {
#     restaurants: [
#       {
#         name: "Restaurant Name",                    # required
#         menus: [
#           {
#             name: "Menu Name",                      # required
#             description: "Menu description",        # optional
#             menu_items: [                           # can also use :dishes as fallback
#               {
#                 name: "Item Name",                  # required
#                 description: "Item description",    # optional
#                 price: 12.99,                       # optional (float)
#                 picture_url: "http://example.com"   # optional
#               }
#               # ... more menu items
#             ]
#           }
#           # ... more menus
#         ]
#       }
#       # ... more restaurants
#     ]
#   }
#
# @return [Hash] Import result with success/error details for each model
#
# Return structure:
#   {
#     general: {
#       success: true/false,                         # overall import success
#       message: "Status message",                   # human-readable status
#       errors: []                                   # array of general errors
#     },
#     restaurants: {
#       success: [                                   # array of successfully imported records
#         { id: 1, name: "Restaurant Name", ... }
#       ],
#       errors: [                                    # array of failed records with details
#         { name: "Failed Restaurant", description: "Failed to create or update record" }
#       ]
#     },
#     menus: {
#       success: [...],                              # successfully imported menu records
#       errors: [...]                               # failed menu records
#     },
#     menu_items: {
#       success: [...],                              # successfully imported menu item records
#       errors: [...]                               # failed menu item records
#     },
#     menu_menu_items: {
#       success: [...],                              # successfully created menu-item associations
#       errors: [...]                               # failed menu-item associations
#     }
#   }
#
# @note All operations are wrapped in a database transaction. If any step fails,
#       all changes are rolled back to maintain data consistency.
#
# @note The service uses upsert operations, so existing records with matching
#       unique keys will be updated rather than duplicated.
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

    def restaurants_required_fields
      %i[name]
    end

    def menus_unique_by
      %i[name restaurant_id]
    end

    def menus_update_fields
      %i[name description restaurant_id]
    end

    def menus_required_fields
      %i[name]
    end

    def menu_items_unique_by
      %i[name]
    end

    def menu_items_update_fields
      %i[name description price picture_url]
    end

    def menu_items_required_fields
      %i[name]
    end

    def menu_menu_items_unique_by
      %i[menu_id menu_item_id]
    end

    def menu_menu_items_update_fields
      %i[menu_id menu_item_id price]
    end

    def menu_menu_items_required_fields
      []
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
      normalized_data, missing_required_fields = normalized_upsert_data(model_data:, update_fields:, model_namespace:)

      validate_required_fields!(model_namespace:, missing_required_fields:)

      begin
        result = model
          .upsert_all(normalized_data, unique_by:, returning:, on_duplicate: on_duplicate_sql(update_fields))
          .to_a
          .map(&:symbolize_keys)
      rescue ActiveRecord::NotNullViolation
        log_not_null_violation(model_namespace:)

        raise ActiveRecord::Rollback
      end

      if result.length != normalized_data.length
        @result[model_namespace][:errors] << {
          description: custom_message || "Failed to import #{model_namespace} records"
        }

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

    def log_not_null_violation(model_namespace:, missing_required_fields:)
      @result[:general][:errors] << {
        error_record: model_namespace,
        description: "Failed to import #{model_namespace} records"
      }

      @result[model_namespace][:errors] << {
        description: "The following fields are required and are missing: #{missing_required_fields.join(", ")}"
      }
    end

    def on_duplicate_sql(update_fields)
      Arel.sql(update_fields.map { |field| "#{field} = EXCLUDED.#{field}" }.join(", "))
    end

    def validate_required_fields!(model_namespace:, missing_required_fields:)
      return if missing_required_fields.blank?

      log_not_null_violation(model_namespace:, missing_required_fields:)

      raise ActiveRecord::Rollback
    end

    def normalized_upsert_data(model_data:, update_fields:, model_namespace:)
      missing_required_fields = []
      required_fields = send("#{model_namespace}_required_fields")

      # Ensure all records have all required fields, to avoid upsert errors
      normalized_data = model_data.map do |record|
        update_fields.each_with_object({}) do |field, normalized_record|
          missing_required_fields << field if field.in?(required_fields) && record[field].blank?

          normalized_record[field] = record[field]
        end
      end

      # Remove duplicates, keeping the first occurrence, to avoid upsert errors
      normalized_data.uniq! do |record|
        send("#{model_namespace}_unique_by_values", record)
      end

      return normalized_data, missing_required_fields
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
