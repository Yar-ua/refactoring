module DBHelper
  def write_to_file(data)
    File.open(Constants::PATH, 'w') { |f| f.write data.to_yaml }
  end

  def db_accounts
    File.exist?(Constants::PATH) ? YAML.load_file(Constants::PATH) : []
  end

  def updating_db(entity)
    updated_account = db_accounts
    updated_account << entity
    write_to_file(updated_account.reverse.uniq(&:login))
  end
end
