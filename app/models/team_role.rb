class TeamRole < ApplicationRecord
  has_many :team_tags
  belongs_to :team
  has_many :all_team_role_members, class_name: :TeamRoleMember
end
