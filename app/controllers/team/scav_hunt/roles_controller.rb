class Team::ScavHunt::RolesController < Team::ScavHunt::BaseController
  before_action :set_role
  def show
    @role_items_by_tag = @role.team_tags.map do |tag|
      # [tag, @team_scav_hunt.items.joins(:team_tags).where(team_tags: {team_role_id: @role.id})]
      [tag, @team_scav_hunt.items.joins(:team_tags).where(team_tags: {team_role_id: @role.id}).group_by { |item| item.item_tags.all?(&:accepted) ? :accepted : :pending }]
    end.to_h
  end

  private
    def set_role
      @role = @team.team_roles.find(request.path_parameters[:id])
    end
end
