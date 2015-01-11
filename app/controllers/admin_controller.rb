class AdminController < RestrictedController
  # all actions are restricted to an admin
  before_action :signed_in_user
  before_action :admin_user

  def home
    # @user already defined by before filters in RestrictedController
  end

  def download
    @users = User.all
    send_data @users.to_csv, filename: 'lcc_directory_' + Time.current.to_s(:number) + '.csv'
  end

  def upload
  end

  def import
    if params[:file]
      result = User.import(params[:file], current_user, params[:replace])

      if (result[:created_ids].length + result[:updated_ids].length) > 0
        flash.now[:success] = 'Successfully ' +
            (result[:created_ids].length > 0 ? ' created ' + result[:created_ids].length.to_s : '') +
            ((result[:created_ids].length > 0 && result[:updated_ids].length > 0) ? ' and ' : '') +
            (result[:updated_ids].length > 0 ? ' updated ' + result[:updated_ids].length.to_s : '') + ' users'
      end

      if result[:errors].length > 0
        error_messages = []
        warning_messages = []

        result[:errors].each_key do |key|
          count = (result[:errors][key]).size
          message = ' import ' + count.to_s + ' user' + (count > 1 ? 's' : '') + ' due to ' +
              key.to_s.gsub(/_/,' ') + ': ' + result[:errors][key].join(', ')

          if key == :matching_current_user
            warning_messages.push 'Did not' + message
          else
            error_messages.push 'Failed to' + message
          end
        end

        unless error_messages.blank?
          flash.now[:danger] = error_messages.join('<br/>').html_safe
        end

        unless warning_messages.blank?
          flash.now[:warning] = warning_messages.join('<br/>').html_safe
        end
      end
    else
      flash.now[:warning] = 'Upload failure: no file selected'
    end

    user_ids = result[:created_ids] + result[:updated_ids];
    @users = User.find(user_ids) unless user_ids.size > 20
    render 'upload'
  end

end
