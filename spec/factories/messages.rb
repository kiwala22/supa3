FactoryGirl.define do
  factory :message do
    to "MyString"
    from "MyString"
    message "MyText"
    type ""
  end
end
