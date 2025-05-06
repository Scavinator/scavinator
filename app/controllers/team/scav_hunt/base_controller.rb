class Team::ScavHunt::BaseController < Team::BaseController
  before_action :set_team_scav_hunt, :nav_prereqs

  def render(*args, **hargs)
    if @team_scav_hunt
      super(*args, layout: 'team', **hargs)
    else
      super
    end
  end

  private
    def set_team_scav_hunt
      slug_param = request.path_parameters[:slug] || request.path_parameters[:scav_hunt_slug]
      @team_scav_hunt = @team.team_scav_hunts.joins(:scav_hunt).find_by!({scav_hunt: {slug: slug_param}})
    end

    def nav_prereqs
      item_page_numbers = @team_scav_hunt.items.group(:page_number).select(:page_number).where.not(page_number: nil).map(&:page_number)
      page_captain_page_numbers = @team_scav_hunt.page_captains.group(:page_number).select(:page_number).map(&:page_number)
      @page_numbers = [item_page_numbers, page_captain_page_numbers].flatten.uniq.sort
      @my_items = @team_scav_hunt.items.joins(:item_users).where(item_users: {user_id: @user.id})
      @my_roles = @team_scav_hunt.team_role_members.where(user_id: @user.id).map(&:team_role)
    end
end
