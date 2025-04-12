class TeamRole < ApplicationRecord
  has_many :team_role_members
  has_many :team_tags
  belongs_to :team
end
