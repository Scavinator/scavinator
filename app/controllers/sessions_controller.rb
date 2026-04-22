class SessionsController < ApplicationController
  include Discord

  allow_unauthenticated_access only: %i[ new create destroy ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create_discord
    begin
      discord_user = discord_user_info(new_discord_session_url)
    rescue DiscordFetchError
      redirect_to new_session_path, alert: "Could not authenticate you with discord"
    else
      if user = User.find_by!(discord_id: discord_user["id"])
        start_new_session_for user
        redirect_to root_dash_path
      else
        redirect_to new_session_path, alert: "Discord account not linked to a web account"
      end
    end
  end

  def create
    if user = User.authenticate_by(params.slice(:email_address, :password).permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url || root_root_path
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    cookies.delete(:scavinator_authcode)
    terminate_session if resume_session
    if request.path_parameters[:prefix]
      redirect_to team_new_session_path
    else
      redirect_to root_root_path
    end
  end
end
