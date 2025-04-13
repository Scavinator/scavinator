class UsersController < ApplicationController
  include Discord

  allow_unauthenticated_access except: [:edit]
  before_action :set_user_by_cookie, only: [:edit]
  before_action :set_team_by_prefix, only: [:edit]

  def new
    @teams = Team.all
    @signup_type = params[:type] == "captain" ? :captain : :scavvie
  end

  def edit
    flash[:last_team_prefix] = @team.prefix if @team
  end

  def discord_oauth
    db_session = find_session_by_cookie
    if db_session&.user
      access_token = HTTParty.post("https://discord.com/api/oauth2/token", body: {
        grant_type: 'authorization_code',
        code: params.require(:code),
        redirect_uri: helpers.discord_redirect_uri
      }, basic_auth: {
        username: Rails.application.credentials.discord_client_id!,
        password: Rails.application.credentials.discord_client_secret!
      })
      return render body: "Error getting token from discord. Try again?" unless !access_token['access_token'].nil?
      user = DiscordClient.get('/users/@me', headers: {'Authorization' => "Bearer #{access_token['access_token']}"})
      return render body: "Error getting token from discord. Try again?" unless !user['id'].nil? && user.code == 200
      db_session.user.update(discord_id: user["id"])
      if flash[:last_team_prefix]
        if flash[:last_team_path]
          # redirect_to URI::HTTP.build(host: "#{flash[:last_team_prefix]}.#{Rails.configuration.scavinator_domain}", path: flash[:last_team_path], port: request.port), allow_other_host: true
          redirect_to URI.join(team_url(domain: "#{flash[:last_team_prefix]}.#{Rails.configuration.scavinator_domain}"), flash[:last_team_path]), allow_other_host: true
        else
          redirect_to edit_team_user_url(domain: "#{flash[:last_team_prefix]}.#{Rails.configuration.scavinator_domain}"), allow_other_host: true
        end
      else
        redirect_to root_dash_path
      end
    else
      render body: "Can't connect discord when not logged in"
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.create(
        name: params["user_name"],
        email_address: params["email_address"],
        password: params["password"],
        password_confirmation: params["password_again"]
      )
      @team = Team.create(
        affiliation: params["affiliation"],
        prefix: params["prefix"],
        virtual: params["virtual"] == "true" ? true : (params["virtual"] == "false" ? false : nil),
        uchicago: params["uchicago"] == "true" ? true : (params["uchicago"] == "false" ? false : nil)
      )
      TeamUser.create(team_id: @team.id, user_id: @user.id, captain: true, approved: true, invited: false)
    end
    start_new_session_for @user
    redirect_to @team
  end

  private
    def set_team_by_prefix
      @team = Team.find_by(prefix: request.path_parameters[:prefix])
    end
end
