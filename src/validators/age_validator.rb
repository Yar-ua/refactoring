class AgeValidator
  attr_reader :errors, :age

  def initialize(age)
    @errors = []
    @age = age
  end

  def valid?
    @errors << error_message unless Constants::VALID_RANGE[:age].cover?(@age)
    @errors.empty?
  end

  private

  def error_message
    I18n.t(:age_between, min: Constants::VALID_RANGE[:age].min, max: Constants::VALID_RANGE[:age].max)
  end
end
