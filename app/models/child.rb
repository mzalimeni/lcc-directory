class Child < ActiveRecord::Base
  include ModelsHelper
  include DateHelper
  belongs_to :family

  before_save { self.first_name = titleize_with_accents first_name }
  before_save { self.last_name = titleize_with_accents last_name }
  before_save { self.preferred_name = titleize_with_accents preferred_name }
  before_save { self.birthday = format_internal(birthday) }

  #Validations
  VALID_NAME_REGEX = /\A([a-z]+['\.\- ]?)+\z/i

  validates :first_name, presence: true,
            length: {maximum: 20},
            format: {with: VALID_NAME_REGEX, message: "%{value} is not a valid name"}
  validates :last_name, presence: true,
            length: {maximum: 20},
            format: {with: VALID_NAME_REGEX, message: "%{value} is not a valid name"}
  validates :preferred_name, length: {maximum: 20},
            format: {with: VALID_NAME_REGEX, message: "%{value} is not a valid name"},
            allow_blank: true
  validates :family_id, presence: true

  def full_name
    if preferred_name.nil?
      first_name + ' ' + last_name
    else
      preferred_name + ' ' + last_name
    end
  end

end
