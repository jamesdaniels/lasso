def define_oauth_one(parent)
  eval <<OAUTHONE
    class OAuthOne#{parent} < #{parent}

      alias_attribute :oauth_token,        :token_a
      alias_attribute :oauth_token_secret, :token_b

      validates_presence_of :oauth_token, :oauth_token_secret

      def client
        @client ||= OAuth::Consumer.new(config(:key), config(:secret), :site => config(:site), :request_token_path => config(:request_token_path), :authorize_path => config(:authorize_path), :access_token_path => config(:access_token_path))
      end

      def access
        @access ||= OAuth::AccessToken.new(client, oauth_token, oauth_token_secret)
      end

    end
OAUTHONE
end
