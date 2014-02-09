class UsersController < ApplicationController
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
  end

  def edit
    # @user defined by before filters
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


    #Before filters

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
    end

    def admin_user
      redirect_to root_url notice: "Sorry, you are not an administrator." unless current_user.admin?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    end

end
