module Team::ScavHuntsHelper
  def owns_tag?(tag)
    (tag.team_role && TeamRoleMember.exists?(user_id: @user_id, team_scav_hunt_id: @team_scav_hunt.id, team_role_id: tag.team_role.id)) || @team_user.captain
  end
end
