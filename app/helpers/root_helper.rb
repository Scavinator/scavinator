module RootHelper
  def is_admin?
    @user.admin
  end
end
