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
  VALID_NAME_REGEX = /\A[a-zA-Z]+(['\- ][a-zA-Z]+)*\z/i
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
  validates :postal_code, length: {is: 5},
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
  validates :primary_phone, numericality: {in: 0..2}
  validates :password, length: {minimum: 6, if: :changing_password?,
                                message: 'Password must be at least 6 characters'},
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

  def family
    # user's kids + spouse's kids
    User.where('family_id = ? AND id != ?', family_id, id) +
    User.where('family_id = ? AND id != ?', spouse_id, spouse_id)
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

    def self.import(file, current_user, replace=false)
      #if replacing entire database, delete all users not matching the current user
      User.where.not(id: current_user.id).where.not(email: current_user.email).delete_all if replace

      created_ids = []
      updated_ids = []
      errors = {}
      CSV.foreach(file.path, headers: true) do |row|
        row_hash = row.to_hash

        #update date formats to correct the CSV export format
        date = DateTime.strptime(row_hash['birthday'], '%m/%d/%y')
        if date
          birthday_formatted = date.strftime('%Y-%m-%d').to_s
        end
        row_hash['birthday'] = birthday_formatted

        #don't allow the current user to get messed with
        if row_hash['id'] == current_user.id || row_hash['email'].strip == current_user.email
          errors[:matching_current_user] = [current_user.email]
        else
          user = User.find_by_email(row_hash['email'])
          if user
            #found an existing user, so update attributes
            user.update(row_hash)

            if user.errors.blank?
              updated_ids.push user.id
            end
          else
            #import the new user
            temp_pass = row_hash['last_name'] + row_hash['first_name']
            row_hash['password'] = temp_pass
            row_hash['password_confirmation'] = temp_pass

            user = User.create(row_hash)

            if user.errors.blank?
              created_ids.push user.id
            end
          end

          #handle errors
          user.errors.each do |error|
            errors[error] ||= []
            errors[error].push user.email
          end
        end
      end

      #return a hash of the saved and updated user ids, and the errors for the failures
      {created_ids: created_ids, updated_ids: updated_ids, errors: errors}
    end

end
