module ModelsHelper

  VALID_NAME_REGEX = //
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  VALID_STREET_REGEX = //
  VALID_CITY_REGEX = //
  VALID_PHONE_REGEX = //

  def titleize_with_dash(string)
    string.sub('-','#').titlecase.sub('#','-')
  end
end
