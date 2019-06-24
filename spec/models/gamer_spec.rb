require 'rails_helper'
RSpec.describe Gamer, type: :model do
    it { should validate_presence_of (:phone_number) }
    it { should validate_uniqueness_of (:phone_number) }
end