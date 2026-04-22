class Team::AuthcodesController < Team::BaseController
  require_captain
  before_action :set_code, only: [:show, :destroy]

  def new
  end

  def show
    @url = URI(@code.created_for_url)
    @url.query = URI.encode_www_form([*URI.decode_www_form(@url.query || ""), ["authcode", @code.key]])
  end

  def create
    logger.info params
    auth_params = params.require(:team_auth).permit(:key, :create_account, :ui_password)
    auth_params[:key] = SecureRandom.hex(32) unless auth_params[:key].present?
    @team.team_auths.create!(**auth_params.slice(:key, :create_account, :ui_password), creator: @user)
    redirect_to team_authcodes_path
  end

  def create_from_url
    return "Missing referer header" unless request.referer.present?
    referer = URI(request.referer)
    auth_code = @team.team_auths.create!(creator: @user, created_for_url: referer, key: SecureRandom.hex(32))
    auth_uri = referer
    auth_uri.query = URI.encode_www_form([*URI.decode_www_form(referer.query || ""), ["authcode", auth_code.key]])
    @url = auth_uri
    redirect_to team_authcode_path(auth_code)
  end

  def index
    @codes = @team.team_auths
  end

  def destroy
    @code.delete
    redirect_to team_authcodes_path
  end

  private
    def set_code
      @code = @team.team_auths.find_by!(id: params[:id])
    end
end
