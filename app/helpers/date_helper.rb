module DateHelper

  def format_internal(date_string)
    date = DateTime.strptime(date_string, '%m/%d') rescue nil
    date.strftime('%Y-%m-%d').to_s rescue nil
  end

  def format_show(date)
    date.strftime('%B %d').to_s rescue nil
  end

  def format_datepicker(date)
    date.strftime('%m/%d').to_s rescue nil
  end

end