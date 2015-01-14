module RegistrationHelper

  @@registration_end_lock = Mutex.new  # lock for registration datetime

  REGISTRATION_DATETIME_FORMAT =        '%m/%d/%y  %l:%M %p %z'
  REGISTRATION_DATETIME_FORMAT_NO_TZ =  '%m/%d/%y  %l:%M %p'

  def set_registration_end(datetime)
    value = registration_datetime_to_s datetime
    @@registration_end_lock.synchronize do
      begin
        registration_end = NoSql.find_by_key(:registration_end)
        if registration_end
          registration_end.value = value
          registration_end.save
        end
      rescue
        registration_end = NoSql.create(key: :registration_end, value: value)
      end
    end
  end

  def current_registration_end
    registration_end = nil
    @@registration_end_lock.synchronize do
      registration_end = NoSql.find_by_key(:registration_end)
      unless registration_end
        registration_end = NoSql.create(key: :registration_end, value: registration_datetime_to_s(DateTime.new(0)))
      end
    end
    registration_datetime_from_s registration_end.value
  end

  def current_registration_end_to_s_no_tz
    registration_datetime_to_s_no_tz current_registration_end
  end

  def registration_datetime_to_s(datetime)
    datetime.strftime(REGISTRATION_DATETIME_FORMAT)
  end

  def registration_datetime_to_s_no_tz(datetime)
    datetime.strftime(REGISTRATION_DATETIME_FORMAT_NO_TZ)
  end

  def registration_datetime_from_s(string)
    DateTime.strptime(string, REGISTRATION_DATETIME_FORMAT)
  end

  def registration_datetime_from_s_no_tz(string)
    DateTime.strptime(string + ' ' + DateTime.now.strftime('%z'), REGISTRATION_DATETIME_FORMAT)
  end

  def registration_expired
    current_registration_end.to_i < DateTime.now.to_i
  end

end