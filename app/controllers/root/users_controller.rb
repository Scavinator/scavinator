class Root::UsersController < ApplicationController
  allow_unauthenticated_access

  def new
    @teams = Team.all
    @signup_type = params[:type] == "captain" ? :captain : :scavvie
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
end
