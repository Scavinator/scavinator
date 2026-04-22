class Team::UsersController < Team::BaseController
  require_captain except: %i[index new create edit update]
  allow_public_access only: %i[new create]

  allow_pending_user only: %i[edit update]
  before_action :require_user_matches, only: %i[edit update]

  def new
  end

  def edit
  end

  def update
    if @team.team_auths.find_by(key: params.require(:team_user).require(:team_auth_password), create_account: true, ui_password: true)
      @pending_team_user.update(approved: true)
      flash[:success] = "Account approved!"
    else
      flash[:danger] = "Invalid password"
    end
    redirect_to edit_team_user_path((@team_user || @pending_team_user).user.id)
  end

  def create
    can_autoapprove = helpers.current_authcode&.create_account
    if !can_autoapprove && params[:team_auth_password].present?
      team_auth = @team.team_auths.find_by(key: params[:team_auth_password], create_account: true, ui_password: true)
      if !team_auth
        flash[:danger] = "Invalid auto-approve code"
        redirect_to new_team_user_path
        return
      end
      can_autoapprove = true
    end
    ActiveRecord::Base.transaction do
      @user = User.create!(
        name: params["user_name"],
        email_address: params["email_address"],
        password: params["password"],
        password_confirmation: params["password_again"]
      )
      @team.team_users.create(user: @user, approved: can_autoapprove ? true : nil)
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:danger] = e.record.errors.full_messages.join(", ")
    redirect_to new_team_user_path
  else
    start_new_session_for @user
    redirect_to team_path
  end

  def index
    @members = @team.team_users.where(approved: true)
  end

  def index_pending
    @members = @team.team_users.where(approved: nil)
  end

  def index_banned
    @members = @team.team_users.where(approved: false)
  end

  def manage
    value = params.require(:team_user).require(:approved)
    raise ActionController::BadRequest, "Missing valid team_user.approved value" unless %w[true false].include? value
    @team.team_users.find(request.path_parameters[:id]).update(approved: value == "true")
    redirect_to team_users_path
  end

  private
    def require_user_matches
      path_user = User.find(request.path_parameters[:id])
      request_authentication unless @user.id == path_user.id
    end
end
