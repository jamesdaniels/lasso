require 'rubygems'
require 'active_record'
require 'action_controller'
require 'oauth2'
require 'oauth'

module Lasso
  
  autoload :Controller, 'lasso/controller/base'
  autoload :Model,      'lasso/model/base'
  
  def processes_oauth_transactions_for(model, settings = {})
    include Lasso::Controller
    self.oauth_model = model
    self.oauth_settings = settings
  end
  
  def oauth
    include Lasso::Model
    yield if block_given?
  end
  
end

ActiveRecord::Base.extend Lasso
ActionController::Base.extend Lasso