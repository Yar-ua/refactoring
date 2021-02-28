class CardsConsole
  include ConsoleHelper
  include CardsHelper

  def initialize(account)
    @account = account
  end

  def cards_choices(command)
    return output(I18n.t('ERROR.no_active_cards')) if @account.cards.empty?

    case command
    when COMMANDS[:card_destroy] then destroy_account_card
    when COMMANDS[:put_money] then put_account_money(command)
    when COMMANDS[:withdraw_money] then withdraw_account_money(command)
    when COMMANDS[:send_money] then send_account_money(command)
    end
    updating_db(@account)
  end

  def destroy_account_card
    output(I18n.t('common_phrases.if_you_want_to_delete'))
    chosen_card = select_card
    return if chosen_card.nil?

    output(I18n.t('destroying_message', card: chosen_card.number))
    return unless yes?

    @account.cards.delete(chosen_card)
  end

  def put_account_money(command)
    operation = validate_operation(command)
    return if operation.nil?

    amount, card = card_amount(operation)
    return output(I18n.t('ERROR.tax_higher')) unless card.operation_put_valid?(amount)

    card.put_money(amount)
    output(I18n.t('common_phrases.after_put',
                  card_attributes(amount, card, card.put_tax(amount))))
  end

  def validate_operation(command)
    action = COMMANDS.key(command)
    output(I18n.t("operations.choose_card.#{action}"))
    chosen_card = select_card
    return if chosen_card.nil?

    output(I18n.t("operations.amount.#{action}"))
    amount = validate_amount
    return if amount.nil?

    { chosen_card: chosen_card, amount: amount }
  end

  def validate_amount
    amount = user_input.to_i
    amount.positive? ? amount : output(I18n.t('ERROR.correct_amount'))
  end

  def withdraw_account_money(command)
    operation = validate_operation(command)
    return if operation.nil?

    amount, card = card_amount(operation)
    return output(I18n.t('ERROR.no_money_left')) unless card.operation_withdraw_valid?(amount)

    card.withdraw_money(amount)
    output(I18n.t('common_phrases.after_withdraw',
                  card_attributes(amount, card, card.sender_tax(amount))))
  end

  def send_account_money(command)
    operation = validate_operation(command)
    return if operation.nil?

    amount, sender_card = card_and_amount(operation)
    output(I18n.t('common_phrases.recipient_card'))

    recipient_card = recipient_card_validation
    return if recipient_card.nil?

    return unless validate_send_operation_taxes(sender_card, recipient_card, amount)

    send_money_operation(sender_card, recipient_card, amount)
  end

  def validate_send_operation_taxes(sender_card, recipient_card, amount)
    return output(I18n.t('ERROR.no_money_left')) unless sender_card.operation_send_valid?(amount)
    return output(I18n.t('ERROR.no_money_on_recipient')) unless recipient_card.operation_put_valid?(amount)

    true
  end

  def send_money_operation(sender_card, recipient_card, amount)
    sender_card.send_money(amount)
    recipient_card.put_money(amount)
    output(I18n.t('common_phrases.after_withdraw',
                  card_attributes(amount, sender_card, sender_card.sender_tax(amount))))
    output(I18n.t('common_phrases.after_put',
                  card_attributes(amount, recipient_card, recipient_card.put_tax(amount))))
  end

  def recipient_card_validation
    input_number = user_input
    return output(I18n.t('ERROR.invalid_number')) if input_number.size != Card::CARD_NUMBERS

    found_card = @account.cards.detect { |card| card.number == input_number }
    found_card.nil? ? output(I18n.t('ERROR.not_exist_card_number', number: input_number)) : found_card
  end

  def select_card
    show_cards_for_destroying
    choice = user_input
    return if back?(choice)

    return output(I18n.t('ERROR.wrong_number')) unless (1..@account.cards.size).cover?(choice.to_i)

    @account.find_card_by_index(choice)
  end

  def show_cards_for_destroying
    @account.cards.each_with_index do |card, index|
      output(I18n.t('common_phrases.show_cards_for_destroying',
                    number: card.number,
                    type: card.type,
                    index: index + 1))
    end
    output(I18n.t('press_exit'))
  end
end
