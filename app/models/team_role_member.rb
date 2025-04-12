class TeamRoleMember < ApplicationRecord
  belongs_to :user
  belongs_to :team_scav_hunt
  belongs_to :team_role
end
