class User < ActiveRecord::Base
  include ModelsHelper
  belongs_to :family

  has_secure_password

  before_create :create_remember_token
  before_save { self.first_name = titleize_with_accents first_name }
  before_save { self.last_name = titleize_with_accents last_name }
  before_save { self.preferred_name = titleize_with_accents preferred_name }
  before_save { self.city = titleize_with_accents city }
  before_save { self.email = email.downcase }

  #Validations
  VALID_NAME_REGEX = /\A[a-zA-Z]+(['\-][a-zA-Z]+)*\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  VALID_STREET_REGEX = /\A[1-9]+[0-9]{0,8}[a-zA-Z]? [a-zA-Z]+(['\- ][a-zA-Z]+)* [A-Z][a-zA-Z]{1,10}\.?\z/i
  VALID_CITY_REGEX = VALID_NAME_REGEX

  validates :first_name, presence: true,
            length: {maximum: 20},
            format: {with: ModelsHelper}
  validates :last_name, presence: true,
            length: {maximum: 20},
            format: {with: VALID_NAME_REGEX}
  validates :preferred_name, length: {maximum: 20},
            format: {with: VALID_NAME_REGEX}
  validates :street_address, format: {with: VALID_STREET_REGEX}
  validates :city, length: {maximum: 30},
            format: {with: VALID_CITY_REGEX}
  validates :state, length: {is: 2},
            inclusion: {in: %w(AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY),
                        message: "%{value} is not a valid state"}
  validates :postal_code, length: {is: 5}
  validates :email, presence: true,
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :mobile_phone, format: {with: VALID_PHONE_REGEX}
  validates :home_phone, format: {with: VALID_PHONE_REGEX}
  validates :work_phone, format: {with: VALID_PHONE_REGEX}
  validates :primary_phone, numericality: {greater_than: -1,
                                           less_than: 3}
  validates :password, length: {minimum: 6}

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def full_name
    if preferred_name.nil?
      first_name + ' ' + last_name
    else
      preferred_name + ' ' + last_name
    end
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

end
