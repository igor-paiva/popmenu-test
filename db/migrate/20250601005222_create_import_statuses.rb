class CreateImportStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :import_statuses do |t|
      t.string :status, null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.string :error_message
      t.text :error_backtrace
      t.json :result_data, null: false, default: {}
      t.timestamps
    end
  end
end
