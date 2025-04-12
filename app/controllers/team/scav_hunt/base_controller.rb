class Team::ScavHunt::BaseController < Team::BaseController
  before_action :set_team_scav_hunt

  private
    def set_team_scav_hunt
      @team_scav_hunt = @team.team_scav_hunts.find_by!(slug: request.path_parameters[:slug] || request.path_parameters[:scav_hunt_slug])
    end
end
