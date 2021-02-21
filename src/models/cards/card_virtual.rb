# frozen_string_literal: true

# require_relative 'card'

class CardVirtual < Card
  attr_accessor :number, :balance, :type

  DEFAULT_BALANCE = 150.00

  TAXES = {
    withdraw: 0.88,
    put: 1,
    sender: 1
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

  def sender_tax(_amount)
    TAXES[:sender]
  end
end
