module UsersHelper

  #unused - meant for AJAX name completion with widget add-on
  def update_user_names_hashmap
    if @_users_updated || @_user_names_cache.nil?
      @_user_names_cache = []
      User.all do |u|
        @_user_names_cache << u.full_name
      end
      @_users_updated = false
    end
  end

  def find_users_matching(query)
    @users = []
    tokens = query.split
    if tokens.size == 1
      find_users_like(query)
    else
      count = 1
      while count < tokens.size
        @users += User.where("LOWER(first_name) = ? AND LOWER(last_name) = ?", tokens[count - 1].downcase, tokens[count].downcase)
        count += 1
      end
    end
  end

  def find_users_like(query)
    @users = []
    query.split.each do |s|
      @users += User.where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", "%#{s.downcase}%", "%#{s.downcase}%")
    end
    @users.uniq!
  end

end
