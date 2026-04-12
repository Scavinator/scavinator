class Team::AuthcodesController < Team::BaseController
  require_captain

  def create
    return "Missing referer header" unless request.referer.present?
    referer = URI(request.referer)
    auth_code = @team.team_auths.create!(creator: @user, created_for_url: referer, key: SecureRandom.hex(32))
    auth_uri = referer
    auth_uri.query = URI.encode_www_form([*URI.decode_www_form(referer.query || ""), ["authcode", auth_code.key]])
    @url = auth_uri
  end

  def index
    @codes = @team.auth_codes
  end

  def destroy
  end
end
