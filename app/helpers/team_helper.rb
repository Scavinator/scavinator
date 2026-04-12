module TeamHelper
  def captain?
    @team_user != nil && @team_user.captain
  end

  def team_user?
    @team_user != nil
  end
end
