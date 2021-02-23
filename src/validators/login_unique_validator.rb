class LoginUniqueValidator
  include DBHelper

  attr_accessor :errors, :login
  def initialize(login)
    @errors = []
    @login = login
  end

  def valid?
    @errors << I18n.t(:account_exists) if account_exists?
    @errors.empty?
  end

  private

  def account_exists?
    !db_accounts.detect { |account_in_db| account_in_db.login == @login }.nil?
  end
end
