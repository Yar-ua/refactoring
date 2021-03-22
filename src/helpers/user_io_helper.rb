module UserIOHelper
  def enter_age
    puts I18n.t('ask.age')
    user_input.to_i
  end

  def enter_password
    puts I18n.t('ask.password')
    user_input
  end

  def enter_login
    puts I18n.t('ask.login')
    user_input
  end

  def enter_name
    puts I18n.t('ask.name')
    user_input
  end
end
