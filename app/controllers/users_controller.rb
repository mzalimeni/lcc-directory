class UsersController < RestrictedController
  include UsersHelper

  before_action :signed_in_user,    only: [:edit, :update, :destroy]
  before_action :correct_user,      only: [:edit, :update]
  before_action :admin_user,        only: [:destroy]
  before_action :allowed_to_create, only: [:new, :create]

  helper_method :family_options
  helper_method :spouse_options

  def new
    if params[:promoting]
      @user = User.new(user_params)
      @promoting = params[:promoting]
    else
      get_promoting # clear session variable in case it has a stale value
      @user = User.new
    end
  end

  def create
    @user = User.new(user_params)
    if is_promoting?
      if promotion_valid?
        @promoted = params[:promoting]
      else
        flash[:danger] = 'Invalid child promotion!'
        redirect_from_cancelled_edit
        return # short circuit 'create' operations
      end
    end
    if @user.save
      flash[:success] = 'User successfully created!'
      cleanup_promotion
      if current_user
        redirect_to @user
      else
        # this is a registration - change success and go home
        flash[:success] = 'Thank you! Please log in to continue'
        redirect_to root_path
      end
    else
      store_promoting @promoted # reset session variable since the form has to be resubmitted
      @promoting = @promoted # same for hidden field, since it's not tied to @user
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
    user = User.find(params[:id])
    children = user.children
    if user.destroy
      success = 'User'
      if children.size > 0
        children.each do |child|
          child.destroy
        end
        success += ' and children'
      end
      flash[:success] = success + ' deleted'
    end
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
      :password, :password_confirmation,
      :promoting # supports child > user promotion, not stored in user model
    def user_params
      if current_user && current_user.admin?
        params.require(:user).permit(BASIC_USER_PARAMS + ADMIN_USER_PARAMS)
      else
        params.require(:user).permit(BASIC_USER_PARAMS)
      end
    end

    def prepare_to_return
      @users = @users.sort_by! {|user| user.last_name}
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

    def is_promoting?
      !params[:promoting].blank?
    end

    def promotion_valid?
      # check to see if a promotion is valid
      child_id = get_promoting
      child_id && (child_id.to_s == params[:promoting])
    end

    def cleanup_promotion
      if @promoted
        Child.delete(@promoted)
        flash[:success] = 'Child successfully promoted to user!'
      end
    end

end
