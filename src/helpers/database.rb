module Database
  PATH = 'accounts.yml'

  def write_to_file(data)
    File.open(PATH, 'w') { |f| f.write data.to_yaml }
  end

  def db_accounts
    File.exist?(PATH) ? YAML.load_file(PATH) : []
  end

  def updating_db(entity)
    updated_account = db_accounts
    updated_account << entity
    write_to_file(updated_account.reverse.uniq(&:login))
  end
end
