class PasswordValidator
  attr_reader :errors, :password

  def initialize(password)
    @errors = []
    @password = password
  end

  def valid?
    check_presence
    check_min_length if @errors.empty?
    check_max_length if @errors.empty?
    @errors.empty?
  end

  private

  def check_presence
    @errors << I18n.t(:password_must_present) if @password.empty?
  end

  def check_min_length
    @errors << I18n.t(:password_has_6_and_more_symbols) if min_length?
  end

  def check_max_length
    @errors << I18n.t(:password_has_30_and_less_symbols) if max_length?
  end

  def min_length?
    @password.size < Constants::VALID_RANGE[:password].min
  end

  def max_length?
    @password.size > Constants::VALID_RANGE[:password].max
  end
end
