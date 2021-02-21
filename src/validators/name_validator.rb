class NameValidator
  attr_accessor :errors, :name

  def initialize(name)
    @errors = []
    @name = name
  end

  def valid?
    @errors.push(I18n.t(:name_must_not_be_empty)) if @name.empty?
    @errors.push(I18n.t(:name_capitalized)) unless capitalized?
    @errors.empty?
  end

  private

  def capitalized?
    @name.capitalize[0] == @name[0]
  end
end
