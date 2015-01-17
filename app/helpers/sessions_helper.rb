module SessionsHelper

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user=@user)
    user == current_user
  end

  def admin_user?(user=current_user)
    user ? user.admin? : false
  end

  def sign_out
    current_user.update_attribute(:remember_token, 
				  User.encrypt(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end

  def redirect_from_cancelled_edit
    redirect_to(session[:return_from_edit_url])
    session.delete(:return_from_edit_url)
  end

  def store_edit_return(url)
    session[:return_from_edit_url] = url
  end

  def store_promoting(child_id)
    session[:promoting] = child_id
  end

  def get_promoting
    child_id = session[:promoting]
    session.delete(:promoting)
    return child_id
  end

  def last_search
    session[:last_search]
  end

  def store_last_search(query)
    session[:last_search] = query
  end

end
