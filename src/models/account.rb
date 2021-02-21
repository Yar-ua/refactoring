class Account
  attr_reader :name, :login, :password, :errors, :cards

  include Database

  VALID_RANGE = {
    age: (23..90),
    login: (4..20),
    password: (6..30)
  }.freeze

  def initialize(data)
    @name = data[:name]
    @age = data[:age].to_i
    @login = data[:login]
    @password = data[:password]
    @cards = []
    @errors = []
  end

end
