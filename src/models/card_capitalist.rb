class CardCapitalist < Card
  attr_accessor :number, :balance, :type

  DEFAULT_BALANCE = 100.00

  TAXES = {
    withdraw: 0.04,
    put: 10,
    sender: 0.1
  }.freeze

  def initialize(type)
    @type = type
    @balance = DEFAULT_BALANCE
    super()
  end

  def withdraw_tax(amount)
    amount * TAXES[:withdraw]
  end

  def put_tax(_amount)
    TAXES[:put]
  end

  def sender_tax(amount)
    amount * TAXES[:sender]
  end
end
