class Card
  attr_accessor :balance, :number, :type

  def initialize
    @number = generate_number
  end

  def generate_number
    Array.new(Constants::NUMBER_OF_CARD_SIZE) { rand(Constants::CARD_NUMBERS) }.join
  end

  def self.find_type(input)
    Constants::CARD_TYPES.value?(input)
  end

  def put_money(amount)
    @balance += amount - put_tax(amount)
  end

  def operation_put_valid?(amount)
    amount >= put_tax(amount)
  end

  def withdraw_money(amount)
    amount - withdraw_tax(amount)
  end

  def operation_withdraw_valid?(amount)
    (@balance - amount - withdraw_tax(amount)).positive?
  end

  def send_money(amount)
    @balance -= amount - sender_tax(amount)
  end

  def operation_send_valid?(amount)
    !(@balance - amount - sender_tax(amount)).negative?
  end

  def calculate_tax(amount, percent_tax, fixed_tax)
    amount * percent_tax + fixed_tax
  end

  private

  def withdraw_tax(amount)
    raise NotImplementedError
  end

  def put_tax(amount)
    raise NotImplementedError
  end

  def sender_tax(_amount)
    raise NotImplementedError
  end
end
