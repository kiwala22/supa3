class AccessUser < ApplicationRecord
  audited

  has_one :auth_token

  before_save :ensure_auth_token

  def ensure_auth_token
    if token.blank?
      self.token = generate_auth_token
    end
  end

  private

  def generate_auth_token
    loop do
      token = Devise.friendly_token
      break token unless AccessUser.where(token: token).first
    end
  end

end
