class ImportRestaurantsJob < ApplicationJob
  queue_as :default

  def perform(import_status_id)
    import_status = ImportStatus.find_by(id: import_status_id)

    return unless import_status

    import_status.update!(status: :in_progress, started_at: Time.zone.now)

    params = JSON.parse(import_status.file.download).with_indifferent_access

    result_data = ImportRestaurants.run(params)

    if result_data[:general][:success]
      import_status.update!(status: :completed, result_data:, finished_at: Time.zone.now)
    else
      import_status.update!(
        status: :failed, result_data:, finished_at: Time.zone.now,
        error_message: "Import failed with errors"
      )
    end
  rescue StandardError => e
    import_status.update!(
      status: :failed,
      error_message: "Import failed with unknown error",
      error_backtrace: e.full_message,
      finished_at: Time.zone.now
    )
  end
end
