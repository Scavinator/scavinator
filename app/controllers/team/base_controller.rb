class Team::BaseController < ApplicationController
  skip_before_action :require_authentication
  before_action :set_team_by_prefix, :persist_authcode, :handle_auth # :require_team_user, :require_authentication_or_authcode

  ACCESS_TYPES = [:public, :authcode, :team_user, :captain, :pending_team_user]

  def self.allow_authcode_access(**options)
    # skip_before_action :require_team_user, **options
    # prepend_before_action :enable_require_authentication_or_authcode, **options
    prepend_before_action(**options) do
      @__access_type = :authcode
    end
  end

  def self.allow_public_access(**options)
    prepend_before_action(**options) do
      @__access_type = :public
    end
    # skip_before_action :require_team_user, **options
  end

  def self.require_captain(**options)
    prepend_before_action(**options) do
      @__access_type = :captain
    end
  end

  def self.allow_pending_user(**options)
    prepend_before_action(**options) do
      @__access_type = :pending_team_user
    end
  end

  private
    def handle_auth
      @__access_type = :team_user if @__access_type.nil?
      throw "Invalid access type #{@__access_type}" unless ACCESS_TYPES.include? @__access_type
      try_set_team_user
      return if @__access_type == :public
      return if @__access_type == :pending_team_user && (@team_user || @pending_team_user)
      return if @__access_type == :authcode && has_authcode?
      if !@team_user
        if @__access_type == :captain
          raise HTTP404Exception
        else
          return request_authentication
        end
      end
      if @__access_type == :captain && !@team_user.captain
        raise HTTP404Exception
      end
    end

    def has_authcode?
      @team.team_auths.find_by(key: cookies.signed[:scavinator_authcode]) || @pending_team_user
    end

    def set_team_by_prefix
      @team = Team.find_by!(prefix: request.path_parameters[:prefix])
    end

    def persist_authcode
      key = params[:authcode] || cookies.signed[:scavinator_authcode]
      auth_code = @team.team_auths.find_by(key: key)
      cookies.signed[:scavinator_authcode] = auth_code.key if auth_code
    end

    def try_set_team_user
      if find_session_by_cookie && (@user = find_session_by_cookie.user)
        if team_user = TeamUser.find_by(team_id: @team.id, user_id: @user.id, approved: [nil, true])
          if team_user.approved
            logger.info "Adding team user to req"
            @team_user = team_user
          else
            logger.info "Adding pending team user to req"
            @pending_team_user = team_user
          end
        end
      end
    end

    # We need to separate this like it is because it MUST go before nav_prereqs in
    # Team::ScavHunt::BaseController and so it has to get inserted at this position
    # in the callback chain. If it was not, a caller of allow_authcode_access would
    # remove it and re-insert it at the top, after nav_prereqs (which is always defined
    # earlier because it happens in the base and allow_authcode_access is defined in
    # the controller)
    # def enable_require_authentication_or_authcode
    #   @__enable_require_authentication_or_authcode = true
    # end

    # def require_authentication_or_authcode
    #   return unless @__enable_require_authentication_or_authcode
    #   logger.info "TRY AUTH OR CODE"
    #   try_set_team_user
    #   request_authentication unless @team_user.present? || @team.team_auths.find_by(key: cookies.signed[:scavinator_authcode])
    # end

    # def require_team_user
    #   try_set_team_user
    #   logger.info "TU: #{@team_user}"
    #   request_authentication unless @team_user.present?
    # end

    # def require_captain
    #   # Seems to be the best way to get a 404 :/
    #   raise ActiveRecord::RecordNotFound, "Not a captain" unless @team_user.captain
    # end
end
