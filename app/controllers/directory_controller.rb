class DirectoryController < ApplicationController
  def home
  end

  def login
  end

  def view
    @users = User.paginate(page: params[:page])
  end
end
