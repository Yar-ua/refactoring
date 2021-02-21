module ConsoleHelper
  include UserIOHelper
  include Database

  COMMANDS = {
    create: 'create',
    load: 'load',
    yes: 'y',
    exit: 'exit',
    show_cards: 'SC',
    delete_account: 'DA',
    card_create: 'CC',
    card_destroy: 'DC',
    put_money: 'PM',
    withdraw_money: 'WM',
    send_money: 'SM'
  }.freeze

  def back?(input)
    input == COMMANDS[:exit]
  end

  def run_exit
    exit
  end

  def yes?
    user_input == COMMANDS[:yes]
  end

  def user_input
    gets.chomp
  end

  def output(message)
    puts message
  end
end
