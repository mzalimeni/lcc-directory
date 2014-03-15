module ModelsHelper

  def titleize_with_accents(string)
    unless string.nil?
      string.sub('-','#').sub('\'','$').titlecase.sub('#','-').sub('$','\'')
    end
  end

end
