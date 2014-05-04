class DirectoryController < ApplicationController
  def home
  end

  def index
    @users = User.all
    respond_to do |format|
      format.csv { send_data @users.to_csv }
    end
  end

end
