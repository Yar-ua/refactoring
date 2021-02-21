# frozen_string_literal: true

# require_relative 'card'

class CardUsual < Card
  attr_accessor :number, :balance, :type

  DEFAULT_BALANCE = 50.00

  TAXES = {
    withdraw: 0.05,
    put: 0.02,
    sender: 20
  }.freeze

  def initialize(type)
    @type = type
    @balance = DEFAULT_BALANCE
    super()
  end

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
