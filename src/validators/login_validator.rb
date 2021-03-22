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
    @errors << I18n.t(:login_present) if @login.empty?
  end

  def check_length
    @errors << error_login_longer if @login.size < Constants::VALID_RANGE[:login].min
    @errors << error_login_less if @login.size > Constants::VALID_RANGE[:login].max
  end

  def check_unique
    @errors << I18n.t(:account_exists) if account_exists?
  end

  def error_login_longer
    I18n.t(:login_longer_than_symbols, number: Constants::VALID_RANGE[:login].min)
  end

  def error_login_less
    I18n.t(:login_less_than_symbols, number: Constants::VALID_RANGE[:login].max)
  end

  def account_exists?
    db_accounts.detect { |account_in_db| account_in_db.login == @login }
  end
end
