class TeamRole < ApplicationRecord
  has_many :team_tags
  belongs_to :team
end
