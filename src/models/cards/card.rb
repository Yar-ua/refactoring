class Card
  include Constants

  attr_accessor :balance, :number, :type

  TAXES = {
    withdraw: 0,
    put: 0,
    sender: 0
  }.freeze

  def initialize
    @number = generate_number
  end

  def generate_number
    Array.new(NUMBER_OF_CARD_SIZE) { rand(CARD_NUMBERS) }.join
  end

  def self.find_type(input)
    CARD_TYPES.value?(input)
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
    (@balance - amount - sender_tax(amount)).positive?
  end

  def calculate_tax(amount, percent_tax, fixed_tax)
    amount * percent_tax + fixed_tax
  end

  private

  def withdraw_tax(amount)
    amount * TAXES[:withdraw]
  end

  def put_tax(amount)
    amount * TAXES[:put]
  end

  def sender_tax(_amount)
    TAXES[:sender]
  end
end
