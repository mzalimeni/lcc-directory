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
  before_save { self.family_id = id if family_id.blank? }
  before_save {
    @previous_spouse = spouse_id_was.blank? ? nil : User.find_by_id(spouse_id_was) if spouse_id_changed?
    @new_spouse = spouse if spouse_id_changed?
  }
  after_save {
    @previous_spouse.update(spouse_id: nil) if @previous_spouse && !@previous_spouse.spouse_id.blank?
    @new_spouse.update(spouse_id: id) if @new_spouse && @new_spouse.spouse_id != id
  }
  after_create {
    if self.family_id.blank?
      self.family_id = self.id
      self.save
    end
  }

  #Validations
  VALID_NAME_REGEX = /\A([a-z]+['\.\- ]?)+\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  VALID_STREET_REGEX = /\A[1-9]+[0-9]{0,8}[a-zA-Z]? [a-zA-Z]+(['\- ][a-zA-Z]+)*( [a-zA-Z0-9]{1,10}\.?)*\z/i
  VALID_CITY_REGEX = /\A[a-zA-Z]+(\. )?(['\- ]?[a-zA-Z]+)*\z/i

  validates :first_name, presence: true,
            length: {maximum: 20},
            format: {with: VALID_NAME_REGEX, message: "%{value} is not a valid name"}
  validates :last_name, presence: true,
            length: {maximum: 20},
            format: {with: VALID_NAME_REGEX, message: "%{value} is not a valid name"}
  validates :preferred_name, length: {maximum: 20},
            format: {with: VALID_NAME_REGEX, message: "%{value} is not a valid name"},
            allow_blank: true
  validates :street_address, format: {with: VALID_STREET_REGEX, message: "%{value} is not a valid street address"},
            allow_blank: true
  validates :city, length: {maximum: 30},
            format: {with: VALID_CITY_REGEX, message: "%{value} is not a valid city"},
            allow_blank: true
  validates :state, length: {is: 2},
            inclusion: {in: %w(AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY),
                        message: "%{value} is not a valid state"},
            allow_blank: true
  validates :postal_code, length: {is: 5}, numericality: {in: 11111..99999},
            allow_blank: true
  validates :email, presence: true,
            format: {with: VALID_EMAIL_REGEX, message: "%{value} is not a valid email"},
            uniqueness: {case_sensitive: false}
  validates :mobile_phone, length: {is: 10},
            allow_blank: true
  validates :home_phone, length: {is: 10},
            allow_blank: true
  validates :work_phone, length: {is: 10},
            allow_blank: true
  validates :password, length: {minimum: 6, if: :changing_password?,
                                message: 'must be at least 6 characters'},
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

  def spouse
    spouse_id.blank? ? nil : User.find_by_id(spouse_id)
  end

  # user's + spouse's adult family members (User, not Child, models)
  def family
    # if this user is head of household, do not return self
    users = User.where(family_id: family_id).where.not(id: id) # all family members minus self
    users += User.where(family_id: spouse_id).where.not(id: id).where.not(id: spouse_id) unless spouse_id.blank? # in spouse's family

    return users
  end

  # user's non-adult children + spouse's non-adult children (Child models)
  def children
    children = Child.where(family_id: family_id)

    # add children of head of household's spouse
    if family_id == id
      # this user is head of household, use current spouse_id
      children += Child.where(family_id: spouse_id) unless spouse_id.blank?
    else
      head_of_household = User.find_by_id(family_id)
      children += Child.where(family_id: head_of_household.spouse_id) unless head_of_household.spouse_id.blank?
    end

    return children
  end

  def everyone_else
    User.where.not(id: id)
  end

  def is_family_owner?
    !family.blank? && family_id == id
  end

  def is_head_of_household?
    is_family_owner? || spouse.try(:is_family_owner?)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

    def changing_password?
      password.present? || password_confirmation.present?
    end

end
