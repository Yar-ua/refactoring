class LoginValidator
  attr_accessor :errors, :login

  def initialize(login)
    @errors = []
    @login = login
  end

  def valid?
    check_present
    check_length
    @errors.empty?
  end

  def check_present
    @errors.push(I18n.t(:login_present)) if @login.empty?
  end

  def check_length
    @errors << I18n.t(:login_longer_than_symbols, number: Account::VALID_RANGE[:login].min) if
        @login.size < Account::VALID_RANGE[:login].min
    @errors << I18n.t(:login_less_than_symbols, number: Account::VALID_RANGE[:login].max) if
        @login.size > Account::VALID_RANGE[:login].max
    @errors.empty?
  end
end
