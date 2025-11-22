class ScavHunt < ApplicationRecord
  has_many :team_scav_hunts
  has_many :teams, through: :team_scav_hunts

  def to_param
    slug
  end
end
