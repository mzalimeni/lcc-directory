module ModelsHelper

  def titleize_with_accents(string)
    string.sub('-','#').sub('\'','$').titlecase.sub('#','-').sub('$','\'')
  end

end
