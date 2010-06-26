$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lasso'
require 'active_record'
require 'active_record/fixtures'
require 'action_controller'
require 'active_support'
require 'spec'
require 'spec/autorun'

# establish the database connection
ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
ActiveRecord::Base.establish_connection('active_record_merge_test')

# load the schema
$stdout = File.open('/dev/null', 'w')
load(File.dirname(__FILE__) + "/db/schema.rb")
$stdout = STDOUT

# load the models
require File.dirname(__FILE__) + '/db/models'
require File.dirname(__FILE__) + '/controllers'


Spec::Runner.configure do |config|
  
end
