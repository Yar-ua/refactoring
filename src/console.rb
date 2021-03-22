class Console
  include ConsoleHelper

  def console_menu
    case user_input(I18n.t(:hello))
    when Constants::COMMANDS[:create] then create_account
    when Constants::COMMANDS[:load] then load_account
    else
      exit
    end
    main_menu
  end

  private

  def create_account
    loop do
      account_params = {
        name: user_input(I18n.t('ask.name')),
        age: user_input(I18n.t('ask.age')),
        login: user_input(I18n.t('ask.login')),
        password: user_input(I18n.t('ask.password'))
      }
      @account = Account.new(account_params)
      @account.valid? ? break : puts(@account.errors.join("\n"))
    end
    update_db(@account)
  end

  def load_account
    accounts_db = db_accounts
    return create_the_first_account if accounts_db.empty?

    loop do
      @account = Account.find_account(login_and_password, accounts_db)
      @account.nil? ? puts(I18n.t('errors.user_not_exists')) : break
    end
  end

  def create_the_first_account
    puts I18n.t(:no_active_account_yet)
    yes? ? create_account : console_menu
  end

  def main_menu
    loop do
      puts I18n.t(:main_menu, name: @account.name)
      case command = choose_menu
      when Constants::COMMANDS[:show_cards] then show_account_cards
      when Constants::COMMANDS[:card_create] then create_new_type_card
      when Constants::COMMANDS[:delete_account] then destroy_account
      when Constants::COMMANDS[:exit] then return exit
      else redirect_to_cards_console(command)
      end
    end
  end

  def choose_menu
    loop do
      command = user_input
      return command if Constants::COMMANDS.value?(command)

      puts I18n.t('errors.wrong_command')
    end
  end

  def show_account_cards
    return puts I18n.t('errors.no_active_cards') if @account.cards.empty?

    show_active_card
  end

  def show_active_card
    @account.cards.each { |card| puts I18n.t('show_cards', number: card.number, type: card.type) }
  end

  def create_new_type_card
    loop do
      type = user_input(I18n.t('create_card_message'))
      break @account.create_new_type_card(type) if Card.find_type(type)

      puts I18n.t('errors.wrong_card_type')
    end
    update_db(@account)
  end

  def destroy_account
    puts I18n.t('destroying_message')
    return unless yes?

    @account.destroy
    exit
  end

  def redirect_to_cards_console(command)
    return puts I18n.t('errors.no_active_cards') if @account.cards.empty?

    CardsConsole.new(@account).cards_choices(command)
  end

  def login_and_password
    { login: user_input(I18n.t('ask.login')), password: user_input(I18n.t('ask.password')) }
  end
end
