class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :issues, dependent: :destroy

  EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP
  PASSWORD_MIN_LENGTH = 12
  PHONE_MIN_DIGITS = 10

  normalizes :email, with: ->(e) { e&.strip&.downcase.presence }
  normalizes :phone, with: ->(p) { p&.gsub(/\D/, "").presence }

  validates :email, format: { with: EMAIL_REGEX, message: "is not a valid email address" },
                    uniqueness: { case_sensitive: false },
                    allow_nil: true
  validates :phone, format: { with: /\A\d{#{PHONE_MIN_DIGITS},15}\z/, message: "must be a valid phone number" },
                    uniqueness: true,
                    allow_nil: true
  validate :email_or_phone_present

  validates :password, length: { minimum: PASSWORD_MIN_LENGTH, maximum: 72 },
                       allow_nil: true

  # Look up a user by an identifier that may be either an email or phone number.
  # The identifier is normalized the same way the stored value was.
  def self.find_by_login(identifier)
    return nil if identifier.blank?

    if identifier.include?("@")
      find_by(email: identifier.strip.downcase)
    else
      digits = identifier.gsub(/\D/, "")
      digits.present? ? find_by(phone: digits) : nil
    end
  end

  # Authenticate with an email-or-phone identifier plus a password.
  def self.authenticate_by_login(identifier:, password:)
    user = find_by_login(identifier)
    user&.authenticate(password) || nil
  end

  def display_name
    email.presence || phone.presence
  end

  private

  def email_or_phone_present
    return if email.present? || phone.present?
    errors.add(:base, "Please provide either an email address or a phone number")
  end
end
