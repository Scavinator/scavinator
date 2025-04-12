class ScavHunt < ApplicationRecord
  has_many :team_scav_hunts
  has_many :teams, through: :team_scav_hunts
end
