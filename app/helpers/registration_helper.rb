module RegistrationHelper

  @@registration_end_lock = Mutex.new  # lock for registration time

  REGISTRATION_TIME_FORMAT =            '%m/%d/%y  %l:%M %p %z'
  REGISTRATION_TIME_FORMAT_NO_TZ =      '%m/%d/%y  %l:%M %p'
  REGISTRATION_TIME_IS_TODAY_FORMAT =   '%l:%M %p'

  def set_registration_end(time)
    value = registration_time_to_s time
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
        registration_end = NoSql.create(key: :registration_end, value: registration_time_to_s(Time.at(0)))
      end
    end
    registration_time_from_s registration_end.value
  end

  def current_registration_end_to_s
    if current_registration_end.today?
      'today at ' + registration_time_to_s_today(current_registration_end)
    else
      if (current_registration_end - 1.day).today?
        'tomorrow at ' + registration_time_to_s_today(current_registration_end)
      else
        registration_time_to_s_no_tz current_registration_end
      end
    end
  end

  def registration_time_to_s(time)
    time.strftime(REGISTRATION_TIME_FORMAT)
  end

  def registration_time_to_s_no_tz(time)
    time.strftime(REGISTRATION_TIME_FORMAT_NO_TZ)
  end

  def registration_time_to_s_today(time)
    time.strftime(REGISTRATION_TIME_IS_TODAY_FORMAT)
  end

  def registration_time_from_s(string)
    Time.strptime(string, REGISTRATION_TIME_FORMAT)
  end

  def registration_time_from_s_no_tz(string)
    Time.strptime(string + ' ' + Time.zone.now.strftime('%z'), REGISTRATION_TIME_FORMAT)
  end

  def registration_expired?
    current_registration_end.to_i < Time.zone.now.to_i
  end

end