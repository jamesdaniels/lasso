module Lasso
  module Model 
    module InstanceMethods
      def config(key)
        oauth_providers[service][key]
      end
      def set_type
        self.type ||= "OAuth#{config(:oauth_version) == 1 && 'One' || 'Two'}#{self.class.to_s}"
      end
      def duplicate
        self.class.find(:first, :conditions => ['service = ? and token_a = ?', service, token_a])
      end
    end
  end
end