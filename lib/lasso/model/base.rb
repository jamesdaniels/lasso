require 'lasso/model/oauth_one'
require 'lasso/model/oauth_two'

module Lasso
  module Model  
    autoload :Settings,        'lasso/model/settings'
    autoload :InstanceMethods, 'lasso/model/instance'
    def self.included(base)
      unless ("OAuthOne".constantize rescue false)
        base.class_eval do
          extend Lasso::Model::Settings
          include InstanceMethods
          validates_presence_of :service
          belongs_to :owner, :polymorphic => true
          before_create :set_type
          cattr_accessor :oauth_providers
        end
        define_oauth_one(base)
        define_oauth_two(base)
      end
    end
  end
end