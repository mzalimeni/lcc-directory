class AdminController < RestrictedController
  include AdminHelper

  helper_method :current_registration_end_to_s
  helper_method :registration_expired

  # all actions are restricted to an admin
  before_action :signed_in_user
  before_action :admin_user

  def home
    # @user already defined by before filters in RestrictedController
  end

  def registration
  end

  def open_registration
    begin
      @end_date = registration_time_from_s_no_tz(params[:end_date])
      if @end_date < (Time.zone.now + 1.minute)
        flash[:warning] = 'Please choose a time that is not in the past'
      else
        set_registration_end(@end_date)
        flash[:success] = 'Registration will be open until ' + current_registration_end_to_s + '!'
      end
    rescue
      flash[:danger] = 'Invalid date range, please try again or contact an administrator'
    end
    redirect_to admin_registration_path
  end

  def close_registration
    begin
      set_registration_end(Time.zone.at(0))
      flash[:success] = 'Registration has been closed'
    rescue
      flash[:danger] = 'Could not close registration - please contact an administrator'
    end
    redirect_to admin_registration_path
  end

  def download
    send_data directory_as_csv, filename: 'lcc_directory_' + Time.current.to_s(:number) + '.csv'
  end

  def upload
  end

  def import
    if params[:file]
      result = import_csv(params[:file], current_user, params[:replace])

      created_user_ids = result[:created_user_ids]
      updated_user_ids = result[:updated_user_ids]
      created_child_ids = result[:created_child_ids]
      updated_child_ids = result[:updated_child_ids]

      if (created_user_ids.length + updated_user_ids.length +
          created_child_ids.length + updated_child_ids.length) > 0
        flash.now[:success] = 'Successfully ' +
            (created_user_ids.length > 0 ? ' created ' + created_user_ids.length.to_s : '') +
            ((created_user_ids.length > 0 && result[:updated_user_ids].length > 0) ? ' and ' : '') +
            (updated_user_ids.length > 0 ? ' updated ' + updated_user_ids.length.to_s : '') +
            ((created_user_ids.length > 0 || updated_user_ids.length > 0) ? ' users' : '') +

            ((created_user_ids.length > 0 || updated_user_ids.length > 0) &&
                (created_child_ids.length > 0 || updated_child_ids.length > 0) ? ' and ' : '') +

            (created_child_ids.length > 0 ? ' created ' + created_child_ids.length.to_s : '') +
            ((created_child_ids.length > 0 && updated_child_ids.length > 0) ? ' and ' : '') +
            (updated_child_ids.length > 0 ? ' updated ' + updated_child_ids.length.to_s : '') +
            ((created_child_ids.length > 0 || updated_child_ids.length > 0) ? ' children' : '')
      end

      # handle errors

      error_messages = []
      warning_messages = []

      user_errors = result[:user_errors]
      if user_errors.length > 0
        user_errors.each_key do |key|
          count = (user_errors[key]).size
          message = ' import ' + count.to_s + ' user' + (count > 1 ? 's' : '') + ' due to ' +
              key.to_s.gsub(/_/,' ') + ': ' + user_errors[key].join(', ')

          if key == :matching_current_user
            warning_messages.push 'Did not' + message
          else
            error_messages.push 'Failed to' + message
          end
        end
      end

      child_errors = result[:child_errors]
      if child_errors.length > 0
        child_errors.each_key do |key|
          count = (child_errors[key]).size
          message = ' import ' + count.to_s + ' child' + (count > 1 ? 'ren' : '') + ' due to ' +
              key.to_s.gsub(/_/,' ') + ': ' + child_errors[key].join(', ')

          error_messages.push 'Failed to' + message
        end
      end

      unless error_messages.blank?
        flash.now[:danger] = error_messages.join('<br/>').html_safe
      end

      unless warning_messages.blank?
        flash.now[:warning] = warning_messages.join('<br/>').html_safe
      end
    else
      flash.now[:warning] = 'Upload failure: no file selected'
    end

    user_ids = result[:created_user_ids] + result[:updated_user_ids];
    @users = User.find(user_ids) unless user_ids.size > 20
    render 'upload'
  end

end
