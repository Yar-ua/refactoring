class Account
  attr_reader :name, :login, :password, :errors, :cards

  include DBHelper

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

  def create_new_type_card(type)
    case type
    when Constants::CARD_TYPES[:usual] then @cards << CardUsual.new(type)
    when Constants::CARD_TYPES[:capitalist] then @cards << CardCapitalist.new(type)
    when Constants::CARD_TYPES[:virtual] then @cards << CardVirtual.new(type)
    end
  end

  def find_card_by_index(choice)
    @cards[choice.to_i - 1]
  end

  def self.find_account(user_data_inputs, account)
    account.detect do |db_account|
      db_account.login == user_data_inputs[:login] && db_account.password == user_data_inputs[:password]
    end
  end

  def validate
    validate_login
    validate_name
    validate_age
    validate_password
  end

  def validate_login
    login_validator = LoginValidator.new(@login)
    @errors << login_validator.errors unless login_validator.valid?
  end

  def validate_name
    name_validator = NameValidator.new(@name)
    @errors << name_validator.errors unless name_validator.valid?
  end

  def validate_age
    age_validator = AgeValidator.new(@age)
    @errors << age_validator.errors unless age_validator.valid?
  end

  def validate_password
    password_validator = PasswordValidator.new(@password)
    @errors << password_validator.errors unless password_validator.valid?
  end

  def destroy
    write_to_file(db_accounts.reject { |account| account.login == @login })
  end
end
