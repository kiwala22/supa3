require 'rails_helper'

describe Broadcast do
    it { should validate_presence_of (:message)}
    it { should validate_presence_of (:status)}
    it { should validate_presence_of (:segment)}
    it { should validate_presence_of (:execution_time)}
    it { should belong_to (:user)}
end