module Constants
  PATH_TO_DB_FILE = 'db/accounts.yml'.freeze

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

  VALID_RANGE = {
    age: (23..90),
    login: (4..20),
    password: (6..30)
  }.freeze

  CARD_TYPES = {
    usual: 'usual',
    capitalist: 'capitalist',
    virtual: 'virtual'
  }.freeze

  NUMBER_OF_CARD_SIZE = 16

  CARD_NUMBERS = 10

  CARD_TAXES = {
    withdraw: 0,
    put: 0,
    sender: 0
  }.freeze
end
