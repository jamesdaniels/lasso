module Lasso
  module Model 
    module Settings
      class Provider
        def method_missing(symbol, *args)
          @settings ||= {}
          @settings[symbol] = args.first
        end
        def to_h
          @settings || {}
        end
      end 
      RequiredSettings = [:site, :key, :secret, :site, :authorize_path, :access_token_path]
      def provider(name, &block)
        raise ArgumentError, 'Need to define the name' if name.blank?
        p = Lasso::Model::Settings::Provider.new
        block.bind(p).call
        settings = p.to_h
        settings[:oauth_version] = settings[:request_token_path].blank? && 2 || 1
        missing_settings = RequiredSettings.map{|s| settings[s].blank? && s || nil}.compact
        raise ArgumentError, "Need to define #{missing_settings.join(', ')} for any provider" unless missing_settings.empty? 
        raise ArgumentError, "Need to define request_token_path for OAuth 1 providers" if settings[:oauth_version] == 1 && settings[:request_token_path].blank?
        self.oauth_providers ||= {}
        self.oauth_providers[name] = settings
      end
    end
    
  end
end