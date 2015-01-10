class UsersController < RestrictedController
  include UsersHelper

  before_action :signed_in_user,  only: [:edit, :update, :create, :destroy]
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: [:create, :destroy]

  helper_method :family_options
  helper_method :spouse_options

  def new
    @user = User.new(user_params)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'User successfully created!'
      redirect_to @user
    else
      render 'new'
    end
  end
 
  def show
    @user = User.find(params[:id])
    unless @user.directory_public
      if signed_in_user('Please sign in to view ' + @user.full_name + '\'s profile')
        # if member is public or user is signed in, allow view - otherwise this forces sign-in, so we're good
      end
    end
    @family = @user.family
    if @user.spouse && !@family.blank?
      # don't show spouse in family list for user view since spouse section exists
      @family -= [@user.spouse]
    end
    @children = @user.children
  end

  def all
    @users = User.all
    prepare_to_return
  end

  def search
    if params[:query].blank?
      redirect_to all_path and return
    end

    query = params[:query].gsub(/[^a-zA-Z ]/i, '').gsub(/ +/, ' ') # normalize input to single space alpha

    find_users_matching query
    if @users.size == 1
      flash[:success] = 'Only one user matched your search!'
      redirect_to @users[0]
    else
      # we've got zero or more than one match, so the shortcut failed - go ahead with full 'like' search
      find_users_like query
      if @users.blank?
        flash[:warning] = 'Sorry, no members matched your search'
        redirect_to root_path
      else
        prepare_to_return
      end
    end
  end

  def edit
    # @user already defined by before filters in RestrictedController
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated'
      @_users_updated = true
      redirect_to @user 
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to root_path
  end

  private

    ADMIN_USER_PARAMS = :admin, :family_id, :spouse_id
    BASIC_USER_PARAMS = :first_name, :last_name, :preferred_name,
      :email,
      :street_address, :city, :state, :postal_code,
      :mobile_phone, :home_phone, :work_phone,
      :birthday,
      :directory_public,
      :password, :password_confirmation
    def user_params
      if current_user.admin?
        params.require(:user).permit(BASIC_USER_PARAMS + ADMIN_USER_PARAMS)
      else
        params.require(:user).permit(BASIC_USER_PARAMS)
      end
    end

    def prepare_to_return
      @users = @users.sort_by! {|user| user.first_name}
      @users = @users.paginate(page: params[:page])
    end

    def family_options
      # everyone besides the user whose id is set to their own (they don't belong to a family)
      @user ? User.where('id = family_id').where.not(id: @user.id) : User.where('id = family_id')
    end

    def spouse_options
      # for married user, just their spouse; for new user or unmarried, anyone unmarried
      @user && @user.spouse.blank? ? @user.everyone_else : User.where(spouse_id: @user.try(:id))
    end

end
