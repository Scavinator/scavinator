module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      prefix = request.path_parameters[:prefix]
      if prefix.nil?
        redirect_to new_session_path
      else
        redirect_to team_new_session_path
      end
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax, domain: Rails.configuration.scavinator_domain }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id, domain: Rails.configuration.scavinator_domain)
    end

    def set_user_by_cookie
      @user = find_session_by_cookie.user
    end
end
