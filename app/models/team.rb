class Team < ApplicationRecord
  has_many :team_users
  has_many :users, through: :team_users
  has_many :team_scav_hunts
  has_many :scav_hunts, through: :team_scav_hunts
  has_many :team_tags
  has_many :team_roles

  def to_param
    self.prefix
  end
end
