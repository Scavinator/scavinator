class Team::ScavHunt::BaseController < Team::BaseController
  before_action :set_team_scav_hunt

  private
    def set_team_scav_hunt
      slug_param = request.path_parameters[:slug] || request.path_parameters[:scav_hunt_slug]
      @team_scav_hunt = @team.team_scav_hunts.joins(:scav_hunt).find_by!({scav_hunt: {slug: slug_param}})
    end
end
