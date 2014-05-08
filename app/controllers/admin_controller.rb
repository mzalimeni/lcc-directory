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

  def import
    if params[:file]
      user_ids = User.import(params[:file], params[:replace])
      flash.now[:success] = params[:replace] ?
          'Database successfully replaced' : 'Successfully imported ' + user_ids.size + ' users'
    else
      flash.now[:danger] = 'Upload failure: no file selected'
    end

    @users = User.find(user_ids) unless params[:replace] || user_ids.size > 20
    render 'upload'
  end

end
