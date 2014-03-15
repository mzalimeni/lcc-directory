module UsersHelper

  def update_user_names_hashmap
    if @_users_updated || @_user_names_cache.nil?
      @_user_names_cache = []
      User.all do |u|
        @_user_names_cache << u.full_name
      end
      @_users_updated = false
    end
  end

  def search_users_with(q)
    @users = []
    q.split.each do |s|
      @users += User.where("first_name LIKE ? or last_name LIKE ?", "%#{s}%", "%#{s}%")
    end
  end

end
