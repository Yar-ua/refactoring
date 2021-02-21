require 'yaml'
require 'pry'
require 'i18n'

I18n.load_path << Dir[File.expand_path("config/locales") + "/*.yml"]
I18n.default_locale = :en

require_relative 'helpers/user_io_helper'

require_relative 'helpers/console_helper'

require_relative 'models/account'
require_relative 'models/console'
