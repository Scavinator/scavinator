class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :team_users
  has_many :teams, through: :team_users

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
