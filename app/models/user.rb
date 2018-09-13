class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: {maximum: Settings.user.name.max_size}
  validates :email, presence: true, length: {maximum: Settings.user.email.max_size},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: Settings.user.password.min_size}

  has_secure_password
  before_save {email.downcase!}

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
      BCrypt::Engine::MIN_COST:
      BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
  end
end
