class PasswordValidator
  attr_accessor :errors, :password

  def initialize(password)
    @errors = []
    @password = password
  end

  def valid?
    @errors << I18n.t(:password_must_present) if @password.empty?
    @errors << I18n.t(:password_has_6_and_more_symbols) if @password.size < Account::VALID_RANGE[:password].min
    @errors << I18n.t(:password_has_30_and_less_symbols) if @password.size > Account::VALID_RANGE[:password].max
    @errors.empty?
  end
end
