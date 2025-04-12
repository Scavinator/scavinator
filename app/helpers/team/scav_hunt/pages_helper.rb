module Team::ScavHunt::PagesHelper
  def page_owner?
    page_cap = @team_scav_hunt.page_captains.find_by(page_number: params[:page_number], user_id: @user.id)
    return page_cap.nil? && !@team_user.captain
  end
end
