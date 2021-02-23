class Console
  include ConsoleHelper

  def console_menu
    output(I18n.t(:hello))
    case user_input
    when COMMANDS[:create] then create_account
    when COMMANDS[:load] then load_account
    else
      run_exit
    end
    main_menu
  end

  def create_account
    loop do
      name = enter_name
      age = enter_age
      login = enter_login
      password = enter_password
      @account = Account.new(name: name, age: age, login: login, password: password)
      @account.valid? ? break : output(@account.errors.join("\n"))
    end
    updating_db(@account)
  end

  def load_account
    accounts_db = db_accounts
    return create_the_first_account if accounts_db.empty?

    loop do
      @account = Account.find_account(login_and_password, accounts_db)
      @account.nil? ? output(I18n.t('ERROR.user_not_exists')) : break
    end
  end

  def create_the_first_account
    puts I18n.t(:no_active_account_yet)
    yes? ? create_account : console_menu
  end

  def main_menu
    loop do
      output(I18n.t(:main_menu, name: @account.name))
      case command = choose_menu
      when COMMANDS[:show_cards] then show_account_cards
      when COMMANDS[:card_create] then create_new_type_card
      when COMMANDS[:delete_account] then destroy_account
      when COMMANDS[:exit] then return run_exit
      else
        redirect_to_cards_console(command)
      end
    end
  end

  def choose_menu
    loop do
      command = user_input
      return command if COMMANDS.value?(command)

      output(I18n.t('ERROR.wrong_command'))
    end
  end

  def show_account_cards
    return output(I18n.t('ERROR.no_active_cards')) if @account.cards.empty?

    show_active_card
  end

  def show_active_card
    @account.cards.each { |card| output(I18n.t('show_cards', number: card.number, type: card.type)) }
  end

  def create_new_type_card
    loop do
      output(I18n.t('CARDS.create_card_message'))
      type = user_input
      break @account.create_new_type_card(type) if Card.find_type(type)

      output(I18n.t('ERROR.wrong_card_type'))
    end
    updating_db(@account)
  end

  def destroy_account
    output I18n.t('destroying_message')
    return unless yes?

    @account.destroy
    run_exit
  end

  def redirect_to_cards_console(command)
    CardsConsole.new(@account).cards_choices(command)
  end

  private

  def login_and_password
    { login: enter_login, password: enter_password }
  end
end
