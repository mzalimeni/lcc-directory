class RestrictedController < ApplicationController

  private

    NOT_ADMINISTRATOR = "Sorry, you're not an administrator"

    #Before filters

    def signed_in_user(notice='Please sign in')
      unless signed_in?
        store_location
        flash[:warning] = notice
        redirect_to signin_url
      end
    end

    def admin_user
      unless current_user.admin?
        flash[:warning] = NOT_ADMINISTRATOR
        redirect_to root_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    end

    def allowed_to_create
      unless !registration_expired? || (current_user && current_user.admin?)
        flash[:warning] = NOT_ADMINISTRATOR
        redirect_to(root_url)
      end
    end

end
