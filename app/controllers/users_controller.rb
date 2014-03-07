class UsersController < RestrictedController

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

    def user_params
      params.require(:user).permit(:name, :email, :password,
      				   :password_confirmation)
    end

end
