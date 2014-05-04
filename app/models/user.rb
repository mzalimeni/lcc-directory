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
  VALID_NAME_REGEX = /\A[a-zA-Z]+(['\- ][a-zA-Z]+)*\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  VALID_STREET_REGEX = /\A[1-9]+[0-9]{0,8}[a-zA-Z]? [a-zA-Z]+(['\- ][a-zA-Z]+)*( [a-zA-Z]{1,10}\.?)*\z/i
  VALID_CITY_REGEX = /\A[a-zA-Z]+(\. )?(['\- ]?[a-zA-Z]+)*\z/i

  validates :first_name, presence: true,
            length: {maximum: 20},
            format: {with: VALID_NAME_REGEX,
                        message: "%{value} is not a valid name"}
  validates :last_name, presence: true,
            length: {maximum: 20},
            format: {with: VALID_NAME_REGEX,
                        message: "%{value} is not a valid name"}
  validates :preferred_name, length: {maximum: 20},
            format: {with: VALID_NAME_REGEX,
                        message: "%{value} is not a valid name"},
            allow_blank: true
  validates :street_address, format: {with: VALID_STREET_REGEX,
                        message: "%{value} is not a valid street address"},
            allow_blank: true
  validates :city, length: {maximum: 30},
            format: {with: VALID_CITY_REGEX,
                        message: "%{value} is not a valid city"},
            allow_blank: true
  validates :state, length: {is: 2},
            inclusion: {in: %w(AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY),
                        message: "%{value} is not a valid state"},
            allow_blank: true
  validates :postal_code, length: {is: 5},
            allow_blank: true
  validates :email, presence: true,
            format: {with: VALID_EMAIL_REGEX,
                        message: "%{value} is not a valid email"},
            uniqueness: {case_sensitive: false}
  validates :mobile_phone, length: {is: 10},
            allow_blank: true
  validates :home_phone, length: {is: 10},
            allow_blank: true
  validates :work_phone, length: {is: 10},
            allow_blank: true
  validates :primary_phone, numericality: {in: 0..2}
  validates :password, length: {minimum: 6, if: :changing_password?},
            confirmation: {if: :changing_password?}

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

  def self.to_csv
    #create the columns array to export, removing secure and ActiveRecord fields and putting 'admin' at the end
    @column_names = (column_names - %w(password_digest remember_token created_at updated_at) - %w(admin) + %w(admin))
    CSV.generate do |csv|
      csv << @column_names
      all.each do |user|
        csv << user.attributes.values_at(*@column_names)
      end
    end
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

    def changing_password?
      password.present? || password_confirmation.present?
    end

end
