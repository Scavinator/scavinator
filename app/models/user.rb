class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :team_users
  has_many :teams, through: :team_users
  has_many :team_auths, foreign_key: :creator_id, class_name: 'TeamAuth'
  has_many :item_submissions, foreign_key: :submitter_id

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
