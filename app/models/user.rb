class User < ApplicationRecord
  audited
  # Include default devise modules. Others available are:
  devise :database_authenticatable,:rememberable, :validatable,:lockable,:timeoutable, :trackable

  validates :first_name, :last_name, :email, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
end
