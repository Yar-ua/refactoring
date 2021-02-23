class LoginValidator
  attr_accessor :errors, :login

  def initialize(login)
    @errors = []
    @login = login
  end

  def valid?
    @errors.push(I18n.t(:login_present)) if @login.empty?
    @errors << I18n.t(:login_longer_than_symbols, number: Account::VALID_RANGE[:login].min) if
        @login.size < Account::VALID_RANGE[:login].min
    @errors << I18n.t(:login_less_than_symbols, number: Account::VALID_RANGE[:login].max) if
        @login.size > Account::VALID_RANGE[:login].max
    @errors.empty?
  end
end
