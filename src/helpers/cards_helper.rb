module CardsHelper
  def card_attributes(amount, card, tax)
    { amount: amount,
      number: card.number,
      balance: card.balance,
      tax: tax }
  end

  def card_amount(operation)
    card = operation[:chosen_card]
    amount = operation[:amount]
    [amount, card]
  end

  def card_and_amount(operation)
    sender_card = operation[:chosen_card]
    amount = operation[:amount]
    [amount, sender_card]
  end
end
