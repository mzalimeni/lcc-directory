class Member < ActiveRecord::Base
  include ModelsHelper
 
  # String format before_save
  ## Titlecase 
  before_save { self.first_name = first_name.titlecase }
  before_save { self.last_name = last_name.titlecase }
  before_save { self.preferred_name = preferred_name.titlecase }
  before_save { self.city = city.sub('-','#').titlecase.sub('#','-') }
  ## Other case
  before_save { self.email = email.downcase }
  before_save { self.city = city.upcase }

  validates :first_name,     presence: true, 
                             length: { maximum: 20 },
                             format: { with: VALID_NAME_REGEX }
  validates :last_name,      presence: true,
                             length: { maximum: 20 }
                             format: { with: VALID_NAME_REGEX }
  validates :preferred_name  length: { maximum: 20 }
                             format: { with: VALID_NAME_REGEX }
  validates :street_address, format: { with: VALID_STREET_REGEX }
  validates :city,           length: { maximum: 30 }
                             format: { with: VALID_CITY_REGEX }
  validates :state,          length: { is: 2 },
                             inclusion: { in: %w(AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY),
                               message: "%{value} is not a valid state" }
  validates :postal_code,    length: { is: 5 } 
  validates :email,          presence: true,
                             format: { with: VALID_EMAIL_REGEX },
                             uniqueness: { case_sensitive: false }
  validates :mobile_phone,   format: { with: VALID_PHONE_REGEX }
  validates :home_phone,     format: { with: VALID_PHONE_REGEX }
  validates :work_phone,     format: { with: VALID_PHONE_REGEX }
  validates :primary_phone,  numericality: { greater_than: 0, 
                               less_than: 3 }

end
