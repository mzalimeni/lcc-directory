class AdminController < RestrictedController
  # all actions are restricted to an admin
  before_action :signed_in_user
  before_action :admin_user

  def home
    # @user already defined by before filters in RestrictedController
  end

  def download
    @users = User.all
    send_data @users.to_csv, filename: 'lcc_directory_' + Time.current.to_s(:number) + '.csv'
  end

  def upload
  end
end
