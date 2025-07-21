class Team::ScavHunt::PagesController < Team::ScavHunt::BaseController
  before_action :require_captain, except: [:show, :edit, :update]
  before_action :require_page_owner, only: [:edit, :update, :destroy]

  def show
    @page_number = params[:page_number]
    @items = @team_scav_hunt.items.where(page_number: @page_number, list_category_id: nil).order(:number)
    @page_captains = @team_scav_hunt.page_captains.where(page_number: @page_number)
    @team_users = @team.team_users.where(approved: true)
  end

  def new
    @team_users = @team.team_users.where(approved: true)
  end

  def create
    @page_number = params[:page_captain][:page_number]
    @team_scav_hunt.page_captains.create(page_number: @page_number, user_id: params[:page_captain][:user_id])
    redirect_to action: :show, page_number: @page_number
  end

  def destroy
    @page_number = params[:page_number]
    @team_scav_hunt.page_captains.find_by!(user_id: params[:page_captain][:user_id], page_number: @page_number).delete
    redirect_to action: :show, page_number: @page_number
  end

  def edit
    # TODO
  end

  def update
    # TODO
  end

  private
    def require_page_owner
      page_cap = @team_scav_hunt.page_captains.find_by(page_number: params[:page_number], user_id: @user.id)
      raise ActiveRecord::RecordNotFound, "Not team captain or page captain" if page_cap.nil? && !@team_user.captain
    end
end
