module Lasso
  module Controller
    module InstanceMethods
      def new
        @oauth = oauth_settings[:for].call.send(oauth_model).new(:service => params[:service])
        redirect
      end

      def create
        @oauth = oauth_settings[:for].call.send(oauth_model).new(:service => params[:service])
        parse_response
        if @oauth.save
          redirect_to '/' #access_key_path(@oauth)
        else
          render :text => @oauth.to_yaml
        end
      end

    protected

      def oauth_callback_url
        @oauth_callback_url ||= oauth_settings[:callback].call
      end

      def version_one?
        @version_one ||= @oauth.config(:oauth_version) == 1
      end

      def parse_response
        if version_one?
          request_token = session[:request_token]
          access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
          @oauth.attributes = {:oauth_token => access_token.params[:oauth_token], :oauth_token_secret => access_token.params[:oauth_token_secret]}
        else
          access_token = @oauth.client.web_server.get_access_token(params[:code], :redirect_uri => oauth_callback_url)
          @oauth.attributes = {:refresh_token => access_token.refresh_token, :access_token => access_token.token}
        end
      end

      def redirect
        if version_one?
          @request_token = @oauth.consumer.get_request_token(:oauth_callback => oauth_callback_url)
          session[:request_token] = @request_token
          redirect_to @request_token.authorize_url
        else
          redirect_to @oauth.client.web_server.authorize_url(:redirect_uri => oauth_callback_url)
        end
      end
    end
  end
end