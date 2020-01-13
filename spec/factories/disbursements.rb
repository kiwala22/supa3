FactoryGirl.define do
  factory :disbursement do
    ext_transaction_id ""
    currency ""
    transaction_id ""
    amount "9.99"
    phone_number ""
    status "MyString"
  end
end
