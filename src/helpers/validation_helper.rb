module ValidationHelper
  def validate_login
    login_validator = LoginValidator.new(@login)
    @errors << login_validator.errors unless login_validator.valid?

    login_unique_validator = LoginUniqueValidator.new(@login)
    @errors << login_unique_validator.errors unless login_unique_validator.valid?
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
