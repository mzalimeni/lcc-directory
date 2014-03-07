class RestrictedController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :create, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:create, :destroy]

  private

    #Before filters

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def admin_user
      redirect_to root_url notice: "Sorry, you are not an administrator." unless current_user.admin?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    end

end
