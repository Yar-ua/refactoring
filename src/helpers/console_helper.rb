module ConsoleHelper
  include Constants
  include UserIOHelper
  include DBHelper

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
