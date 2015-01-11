module AdminHelper

  def directory_as_csv
    # create the columns array to export
    # remove secure and ActiveRecord fields and put 'admin' and 'child' at the end
    @column_names = User.column_names - %w(password_digest remember_token created_at updated_at) - %w(admin) + %w(admin)

    CSV.generate do |csv|
      csv << @column_names + %w(child) # add 'child' here instead so that the below use of @column_names does not fail
      User.all.each do |user|
        csv << user.attributes.values_at(*@column_names).push(false) # add 'false' for child
      end
      Child.all.each do |child|
        csv << child.attributes.values_at(*@column_names).push(true) # add 'true' for child
      end
    end
  end

  # TODO check csv first before deleting all users
  def import_csv(file, current_user, replace=false)

    # users first...
    created_user_ids = []
    updated_user_ids = []
    user_errors = {}

    # if replacing entire database, delete all users not matching the current user
    User.where.not(id: current_user.id).delete_all if replace

    CSV.foreach(file.path, headers: true) do |row|
      row_hash = row.to_hash

      # check for child - if child, skip, otherwise delete so it doesn't mess up creation
      next unless !row_hash['child'] || (row_hash['child'].downcase == 'false')
      row_hash.delete 'child'

      # update date formats to correct the CSV export format
      if !row_hash['birthday'].blank?
        date = DateTime.strptime(row_hash['birthday'], '%m/%d/%y') rescue nil
        if date
          birthday_formatted = date.strftime('%Y-%m-%d').to_s
          row_hash['birthday'] = birthday_formatted
        end
      end

      # don't allow the current user to get messed with
      if row_hash['id'] == current_user.id || row_hash['email'].strip == current_user.email
        user_errors[:matching_current_user] = [current_user.full_name]
      else
        user = User.find_by_email(row_hash['email'])
        if user
          #found an existing user, so update attributes
          user.update(row_hash)

          if user.errors.blank?
            updated_user_ids.push user.id
          end
        else
          # import the new user
          temp_pass = row_hash['last_name'] + row_hash['first_name']
          row_hash['password'] = temp_pass
          row_hash['password_confirmation'] = temp_pass

          user = User.create(row_hash)

          if user.errors.blank?
            created_user_ids.push user.id
          end
        end

        # handle errors
        user.errors.each do |error|
          user_errors[error] ||= []
          user_errors[error].push user.full_name
        end
      end
    end

    # children next...
    created_child_ids = []
    updated_child_ids = []
    child_errors = {}

    # if replacing entire database, delete all children
    Child.delete_all if replace

    CSV.foreach(file.path, headers: true) do |row|
      row_hash = row.to_hash

      # check for child - if not child, skip, otherwise delete so it doesn't mess up creation
      next unless row_hash['child'] && (row_hash['child'].downcase == 'true')
      row_hash.delete 'child'

      # update date formats to correct the CSV export format
      if !row_hash['birthday'].blank?
        date = DateTime.strptime(row_hash['birthday'], '%m/%d/%y') rescue nil
        if date
          birthday_formatted = date.strftime('%Y-%m-%d').to_s
          row_hash['birthday'] = birthday_formatted
        end
      end

      # create child-only hash
      child_hash = {}
      row_hash.each do |key,value|
        if !value.blank?
          child_hash[key] = value
        end
      end

      child = Child.find_by_id(child_hash['id'])
      if child
        #found an existing child, so update attributes
        child.update(child_hash)

        if child.errors.blank?
          updated_child_ids.push child.id
        end
      else
        # import the new child
        child = Child.create(child_hash)

        if child.errors.blank?
          created_child_ids.push child.id
        end
      end

      # handle errors
      child.errors.each do |error|
        child_errors[error] ||= []
        child_errors[error].push child.full_name
      end
    end

    # return a hash of the saved and updated user ids, and the errors for the failures
    { created_user_ids: created_user_ids, updated_user_ids: updated_user_ids, user_errors: user_errors,
      created_child_ids: created_child_ids, updated_child_ids: updated_child_ids, child_errors: child_errors }
  end

end