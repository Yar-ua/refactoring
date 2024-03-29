class CardsConsole
  include ConsoleHelper
  include CardsHelper

  def initialize(account)
    @account = account
  end

  def cards_choices(command)
    case command
    when Constants::COMMANDS[:card_destroy] then destroy_account_card
    when Constants::COMMANDS[:put_money] then put_account_money(command)
    when Constants::COMMANDS[:withdraw_money] then withdraw_account_money(command)
    when Constants::COMMANDS[:send_money] then send_account_money(command)
    end
    update_db(@account)
  end

  private

  def destroy_account_card
    puts I18n.t('common_phrases.if_you_want_to_delete')
    chosen_card = select_card
    return if chosen_card.nil?

    puts I18n.t('destroying_message', card: chosen_card.number)
    return unless yes?

    @account.cards.delete(chosen_card)
  end

  def put_account_money(command)
    card, amount = validate_operation(command)
    return unless [card, amount].all?

    return puts I18n.t('errors.tax_higher') unless card.operation_put_valid?(amount)

    card.put_money(amount)
    puts I18n.t('common_phrases.after_put',
                card_attributes(amount, card, card.put_tax(amount)))
  end

  def validate_operation(command)
    puts I18n.t("operations.choose_card.#{Constants::COMMANDS.key(command)}")
    card = select_card
    return if card.nil?

    puts I18n.t("operations.amount.#{Constants::COMMANDS.key(command)}")
    amount = validate_amount
    return if amount.nil?

    [card, amount]
  end

  def validate_amount
    amount = user_input.to_i
    amount.positive? ? amount : puts(I18n.t('errors.correct_amount'))
  end

  def withdraw_account_money(command)
    card, amount = validate_operation(command)
    return unless [card, amount].all?

    return puts I18n.t('errors.no_money_left') unless card.operation_withdraw_valid?(amount)

    card.withdraw_money(amount)
    puts I18n.t('common_phrases.after_withdraw',
                card_attributes(amount, card, card.sender_tax(amount)))
  end

  def send_account_money(command)
    sender_card, amount = validate_operation(command)
    return unless [card, amount].all?

    puts I18n.t('common_phrases.recipient_card')
    recipient_card = recipient_card_validation
    return if recipient_card.nil?

    return puts I18n.t('errors.no_money_left') unless sender_card.operation_send_valid?(amount)

    return puts I18n.t('errors.no_money_on_recipient') unless recipient_card.operation_put_valid?(amount)

    send_money_operation(sender_card, recipient_card, amount)
  end

  def send_money_operation(sender_card, recipient_card, amount)
    sender_card.send_money(amount)
    recipient_card.put_money(amount)
    puts I18n.t('common_phrases.after_withdraw',
                card_attributes(amount, sender_card, sender_card.sender_tax(amount)))
    puts I18n.t('common_phrases.after_put',
                card_attributes(amount, recipient_card, recipient_card.put_tax(amount)))
  end

  def recipient_card_validation
    input_number = user_input
    return puts I18n.t('errors.invalid_number') if input_number.size != Constants::CARD_NUMBERS

    found_card = @account.cards.detect { |card| card.number == input_number }
    found_card.nil? ? puts(I18n.t('errors.not_exist_card_number', number: input_number)) : found_card
  end

  def select_card
    show_cards_for_destroying
    choice = user_input
    return if back?(choice)

    return puts I18n.t('errors.wrong_number') unless (1..@account.cards.size).cover?(choice.to_i)

    @account.find_card_by_index(choice)
  end

  def show_cards_for_destroying
    @account.cards.each_with_index do |card, index|
      puts I18n.t('common_phrases.show_cards_for_destroying',
                  number: card.number,
                  type: card.type,
                  index: index.next)
    end
    puts I18n.t('press_exit')
  end
end
