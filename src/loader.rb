require 'yaml'
require 'pry'
require 'i18n'

require_relative 'modules/constants'

require_relative 'helpers/db_helper'
require_relative 'helpers/console_helper'
require_relative 'helpers/cards_helper'

require_relative 'validators/login_validator'
require_relative 'validators/name_validator'
require_relative 'validators/age_validator'
require_relative 'validators/password_validator'

require_relative 'models/card'
require_relative 'models/card_capitalist'
require_relative 'models/card_usual'
require_relative 'models/card_virtual'

require_relative 'models/account'
require_relative 'cards_console'
require_relative 'console'

require_relative '../config/i18n'
