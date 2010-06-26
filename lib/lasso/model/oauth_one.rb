def define_oauth_one(parent)
  eval <<OAUTHONE
    class OAuthOne#{parent} < #{parent}

      alias_attribute :oauth_token,        :token_a
      alias_attribute :oauth_token_secret, :token_b

      validates_presence_of :oauth_token, :oauth_token_secret

      def consumer
        @consumer ||= OAuth::Consumer.new(config(:key), config(:secret), :site => config(:site), :request_token_path => config(:request_token_path), :authorize_path => config(:authorize_path), :access_token_path => config(:access_token_path))
      end

      def client
        @client ||= case service
          when 'linkedin'
            LinkedIn::Client.new(config(:key), config(:secret))
          when 'twitter'
            Twitter::OAuth.new(config(:key), config(:secret))
        end
      end

      def access
        unless @access
          client.authorize_from_access(oauth_token, oauth_token_secret)
          @access ||= case service
            when 'linkedin'
              client
            when 'twitter'
              Twitter::Base.new(client)
          end
        end
        @access
      end

    end
OAUTHONE
end