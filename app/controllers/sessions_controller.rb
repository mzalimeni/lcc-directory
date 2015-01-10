class SessionsController < ApplicationController
  
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Sign in and then friendly forward or send to search page
      sign_in user
      flash[:success] = 'Signed in as ' + user.full_name
      redirect_back_or root_url
    else
      # Create an error message and re-render the signin form
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
  
  def destroy
    sign_out
    flash[:success] = 'Signed out successfully'
    redirect_to root_url
  end

  def cancel_edit
    redirect_from_cancelled_edit
  end

end
