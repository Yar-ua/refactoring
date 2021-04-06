module DBHelper
  def write_to_file(data)
    File.open(Constants::PATH_TO_DB_FILE, 'w') { |f| f.write data.to_yaml }
  end

  def db_accounts
    File.exist?(Constants::PATH_TO_DB_FILE) ? YAML.load_file(Constants::PATH_TO_DB_FILE) : []
  end

  def update_db(entity)
    updated_account = db_accounts
    updated_account << entity
    write_to_file(updated_account.reverse.uniq(&:login))
  end
end
