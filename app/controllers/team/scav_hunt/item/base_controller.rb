class Team::ScavHunt::Item::BaseController < Team::ScavHunt::BaseController
  before_action :set_item

  private
    def set_item
      @list_category = ListCategory.find_by!(slug: request.path_parameters[:list_category_slug]) unless request.path_parameters[:list_category_slug].nil?
      @item = @team_scav_hunt.items.find_by!(number: request.path_parameters[:number] || request.path_parameters[:item_number], list_category_id: @list_category&.id)
    end
end
