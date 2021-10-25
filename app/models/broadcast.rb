class Broadcast < ApplicationRecord
  audited
  belongs_to :user
  validates :execution_time, :message,:status, :method, presence: true

  paginates_per 50
end
