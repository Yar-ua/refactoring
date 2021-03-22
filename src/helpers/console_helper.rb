module ConsoleHelper
  include UserIOHelper
  include DBHelper

  def back?(input)
    input == Constants::COMMANDS[:exit]
  end

  def yes?
    user_input == Constants::COMMANDS[:yes]
  end

  def user_input
    gets.chomp
  end

  def output(message)
    puts message
  end
end
