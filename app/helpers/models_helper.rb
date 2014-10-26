module ModelsHelper

  def titleize_with_accents(string)
    retval = ""
    unless string.nil?
      string.gsub('-','#').gsub('\'','$').split.each do |s|
        retval += s.titleize.gsub(' ','').gsub('#','-').gsub('$','\'')
        retval += ' '
      end
      retval.strip!
    end
  end

end
