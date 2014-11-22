module ModelsHelper

  def titleize_with_accents(string)
    str = ''
    unless string.nil?
      string.gsub('-','#').gsub('\'','$').split.each do |s|
        str += s.titleize.gsub(' ','').gsub('#','-').gsub('$','\'')
        str += ' '
      end
      str.strip!
    end
  end

end
