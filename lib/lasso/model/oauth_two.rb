def define_oauth_two(parent)
  eval <<OAUTHTWO
    class OAuthTwo#{parent} < #{parent}

      alias_attribute :access_token,  :token_a
      alias_attribute :refresh_token, :token_b
  
      validates_presence_of :access_token
  
      def client
        @client ||= OAuth2::Client.new(config(:key), config(:secret), :site => config(:site), :authorize_url => config(:authorize_path), :token_url => config(:access_token_path))
      end
  
      def access
        @access ||= OAuth2::AccessToken.new(client, access_token, refresh_token)
      end
    end
OAUTHTWO
end
