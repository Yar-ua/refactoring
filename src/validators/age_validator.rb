class AgeValidator
  attr_accessor :errors, :age

  def initialize(age)
    @errors = []
    @age = age
  end

  def valid?
    @errors << I18n.t(:age_between, min: Account::VALID_RANGE[:age].min, max: Account::VALID_RANGE[:age].max) unless
        (Account::VALID_RANGE[:age]).cover?(@age)
    @errors.empty?
  end
end
