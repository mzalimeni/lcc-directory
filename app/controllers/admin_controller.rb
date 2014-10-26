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

      if result[:user_ids].length > 0
        flash.now[:success] = (params[:replace] ? 'Database successfully replaced with ' : 'Successfully imported ') +
            result[:user_ids].size.to_s + ' users'
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

    @users = User.find(user_ids) unless params[:replace] || user_ids.size > 20
    render 'upload'
  end

end
