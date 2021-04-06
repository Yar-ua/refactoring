class LoginValidator
  include DBHelper

  attr_reader :errors, :login

  def initialize(login)
    @errors = []
    @login = login
  end

  def valid?
    check_present
    check_length if @errors.empty?
    check_unique if @errors.empty?
    @errors.empty?
  end

  private

  def check_present
    @errors << I18n.t('validation.login.present') if @login.empty?
  end

  def check_length
    @errors << too_long_error_message if @login.size < Constants::VALID_RANGE[:login].min
    @errors << too_short_error_message if @login.size > Constants::VALID_RANGE[:login].max
  end

  def check_unique
    @errors << I18n.t('validation.login.exists') if account_exists?
  end

  def too_long_error_message
    I18n.t('validation.login.longer', number: Constants::VALID_RANGE[:login].min)
  end

  def too_short_error_message
    I18n.t('validation.login.shorter', number: Constants::VALID_RANGE[:login].max)
  end

  def account_exists?
    db_accounts.detect { |account_in_db| account_in_db.login == @login }
  end
end
