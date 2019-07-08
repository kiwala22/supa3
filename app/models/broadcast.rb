class Broadcast < ApplicationRecord
  belongs_to :user
  validates :execution_time, :message,:status,:segment, presence: true
end
