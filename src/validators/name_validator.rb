class NameValidator
  attr_reader :errors, :name

  def initialize(name)
    @errors = []
    @name = name
  end

  def valid?
    check_presence
    check_capitalize if @errors.empty?
    @errors.empty?
  end

  private

  def check_presence
    @errors << I18n.t('validation.name.empty_name') if @name.empty?
  end

  def check_capitalize
    @errors << I18n.t('validation.name.first_letter') unless capitalized?
  end

  def capitalized?
    @name.capitalize == @name
  end
end
