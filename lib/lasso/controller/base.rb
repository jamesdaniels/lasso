module Lasso
  module Controller  
    autoload :Settings,        'lasso/controller/settings'
    autoload :InstanceMethods, 'lasso/controller/instance'
    def self.included(base)
      base.class_eval do
        extend Lasso::Controller::Settings
        include InstanceMethods
        cattr_accessor :oauth_model
        cattr_accessor :oauth_settings
      end
    end
  end
end