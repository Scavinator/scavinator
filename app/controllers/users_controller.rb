class UsersController < ApplicationController
  include Discord

  allow_unauthenticated_access except: [:edit, :update]
  before_action :set_user_by_cookie, :require_user_matches, only: [:edit, :update]

  def new
    @teams = Team.all
    @signup_type = params[:type] == "captain" ? :captain : :scavvie
  end

  def edit
  end

  def update
  end

  def link_discord
    db_session = find_session_by_cookie
    if db_session&.user
      state = discord_parse_state(params[:state])
      if state.nil? || db_session.user.id != state["user_id"]
        render body: "Invalid discord state"
      else
        begin
          user = discord_user_info(link_discord_url)
        rescue DiscordFetchError
          return render body: "Error getting token from discord. Try again?" unless !access_token['access_token'].nil?
        end
        db_session.user.update(discord_id: user["id"])
        if state["path"]
          if state["prefix"]
            domain = "#{state['prefix']}.#{Rails.configuration.scavinator_domain}"
          else
            domain = Rails.configuration.scavinator_domain
          end
          redirect_to URI.join(team_url(domain: domain), state['path']), allow_other_host: true
        else
          redirect_to root_dash_path
        end
      end
    else
      render body: "Can't connect discord when not logged in"
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.create!(
        name: params["user_name"],
        email_address: params["email_address"],
        password: params["password"],
        password_confirmation: params["password_again"]
      )
      @team = Team.create!(
        affiliation: params["affiliation"],
        prefix: params["prefix"],
        virtual: params["virtual"] == "true",
        uchicago: params["uchicago"] == "true"
      )
      TeamUser.create!(team_id: @team.id, user_id: @user.id, captain: true, approved: true)
    end
    start_new_session_for @user
    redirect_to @team
  end

  private
    def require_user_matches
      path_user = User.find(request.path_parameters[:id])
      request_authentication unless @user.id == path_user.id
    end
end
