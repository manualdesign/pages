# encoding: utf-8

require 'digest/sha1'
require 'tempfile'

namespace :db do

  desc "Copy production database to current environment"
  task :copy_from_production => :environment do
    db_config = YAML.load_file(Rails.root.join('config', 'database.yml'))
    temp_file = Tempfile.new(db_config[Rails.env]['database'])
    puts "Dumping remote database... (this might take a while)"
    `mysqldump --add-drop-table --single-transaction --allow-keywords --hex-blob --quick -u #{db_config['production']['username']} -p#{db_config['production']['password']} -h #{db_config['production']['host']} --max_allowed_packet=100M #{db_config['production']['database']} > #{temp_file.path}`
    puts "Importing database dump"
    if db_config[Rails.env]['password']
      `mysql -u #{db_config[Rails.env]['username']} -p#{db_config[Rails.env]['password']} -h #{db_config[Rails.env]['host']} #{db_config[Rails.env]['database']} < #{temp_file.path}`
    else
      `mysql -u #{db_config[Rails.env]['username']} -h #{db_config[Rails.env]['host']} #{db_config[Rails.env]['database']} < #{temp_file.path}`
    end
    puts "Done!"
    temp_file.close!
  end

  desc "Fixes double UTF-8 encoding"
  task :fix_double_encoding => :environment do
    config = Rails.configuration.database_configuration[Rails.env]

    puts "Dumping database..."
    temp_file = Tempfile.new(config['database'])
    if config['password']
      dump_command = "mysqldump -u #{config['username']} -p#{config['password']}"
    else
      dump_command = "mysqldump -u #{config['username']}"
    end
    `#{dump_command} --opt --quote-names --skip-set-charset --default-character-set=latin1 -h #{config['host']} --max_allowed_packet=100M #{config['database']} > #{temp_file.path}`

    puts "Importing database dump"
    if config['password']
      mysql_command = "mysql -u #{config['username']} -p#{config['password']}"
    else
      mysql_command = "mysql -u #{config['username']}"
    end
    `#{mysql_command} -h #{config['host']} --default-character-set=utf8 #{config['database']} < #{temp_file.path}`

    puts "Done!"
    temp_file.close!
  end
end
