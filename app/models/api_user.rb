class ApiUser < ApplicationRecord
	validates :api_id, :first_name, presence: true

end
