class UsersController < RestrictedController
  before_action :signed_in_user, only: [:edit, :update, :create, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:create, :destroy]

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "User successfully created!"
      redirect_to @user
    else
      render 'new'
    end
  end
 
  def show
    @user = User.find(params[:id])
    unless @user.directory_public
      if signed_in_user
        # if member is public or user is signed in, allow view - otherwise this forces sign-in, so we're good
      end
    end
  end

  def view
    @users = User.paginate(page: params[:page])
  end

  def edit
    # @user defined by before filters in RestrictedController
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user 
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to admin_url
  end

  private

    BASIC_USER_PARAMS = :first_name, :last_name, :preferred_name,
      :email,
      :street_address, :city, :state, :postal_code,
      :mobile_phone, :home_phone, :work_phone, :primary_phone,
      :birthday,
      :directory_public,
      :password, :password_confirmation
    ADMIN_USER_PARAMS = :admin, :family_id, :spouse_id
      def user_params
        if admin_user
          params.require(:user).permit(BASIC_USER_PARAMS + ADMIN_USER_PARAMS)
        else
          params.require(:user).permit(BASIC_USER_PARAMS)
        end
      end

end
