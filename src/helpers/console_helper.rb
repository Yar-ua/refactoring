module ConsoleHelper
  include DBHelper

  def back?(input)
    input == Constants::COMMANDS[:exit]
  end

  def yes?
    user_input == Constants::COMMANDS[:yes]
  end

  def user_input(message = nil)
    puts message if message
    gets.chomp
  end
end
