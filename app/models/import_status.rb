class ImportStatus < ApplicationRecord
  has_one_attached :file

  enum :status, {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed",
    failed: "failed"
  }

  attribute :result_data, :json, default: {}
end
