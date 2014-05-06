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
    if params[:replace]
      #User.delete_all
      import_users(params[:file])
      flash.now[:success] = 'Database successfully replaced'
    else
      import_users(params[:file])
      flash.now[:success] = 'Import successful!'
    end
    render 'upload'
  end

  def import_users(file)
    user_ids = []
    CSV.foreach(file.path, headers: true) do |row|
      row_hash = row.to_hash
      temp_pass = row.to_hash['last_name']
      row_hash['password'] = temp_pass
      row_hash['password_confirmation'] = temp_pass
      row_hash.delete 'id'

      user = User.new(row_hash)
      user_ids += user.id if user.save
    end
    @users = User.find(user_ids)
  end

end
