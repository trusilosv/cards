require 'rspec'
require 'cards'
require 'yaml'

module Rails
  def self.env
    'test'
  end
end

module Cards
  def self.table_name_prefix
    'cards_'
  end
end

ActiveSupport::Dependencies.autoload_paths << File.dirname(Pathname.new(__FILE__).dirname + '../app/models/cards')

include ActiveRecord::Tasks
config = YAML.load_file('spec/database.yml')
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection config['cards_test']

DatabaseTasks.database_configuration = config
DatabaseTasks.db_dir = 'db'
DatabaseTasks.drop_current('test')
DatabaseTasks.create_current('test')
DatabaseTasks.migrate
