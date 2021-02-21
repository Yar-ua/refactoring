class Account
  attr_reader :name, :login, :password, :errors, :cards

  include Database

  VALID_RANGE = {
    age: (23..90),
    login: (4..20),
    password: (6..30)
  }.freeze

  def initialize(data)
    @name = data[:name]
    @age = data[:age].to_i
    @login = data[:login]
    @password = data[:password]
    @cards = []
    @errors = []
  end

  def valid?
    validate
    @errors.empty?
  end


  def self.find_account(user_data_inputs, account)
    account.detect do |db_acc|
      db_acc.login == user_data_inputs[:login] || db_acc.password == user_data_inputs[:password]
    end
  end

  def validate
    login_validator = LoginValidator.new(@login)
    @errors << login_validator.errors unless login_validator.valid?

    login_unique_validator = LoginUniqueValidator.new(@login)
    @errors << login_unique_validator.errors unless login_unique_validator.valid?

    name_validator = NameValidator.new(@name)
    @errors << name_validator.errors unless name_validator.valid?

    age_validator = AgeValidator.new(@age)
    @errors << age_validator.errors unless age_validator.valid?

    password_validator = PasswordValidator.new(@password)
    @errors << password_validator.errors unless password_validator.valid?
  end

  def destroy
    write_to_file(db_accounts.reject { |account| account.login == @login })
  end
end