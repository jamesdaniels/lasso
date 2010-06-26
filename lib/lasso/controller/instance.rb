module Lasso
  module Controller
    module InstanceMethods
      def new
        @oauth = type.new(:service => params[:service])
        redirect
      end

      def create
        @oauth = type.new(:service => params[:service])
        #@oauth = oauth_settings[:through].call.send(oauth_model).new(:service => params[:service])
        parse_response
        @owner = oauth_settings[:through].bind(self).call
        nested = {"#{oauth_model}_attributes" => [@oauth.attributes]}
        if @owner.update_attributes(nested)
          redirect_to send("#{oauth_model.to_s.singularize}_path", @owner.send(oauth_model).last)
        else
          render :text => @owner.to_yaml
        end
      end

    protected

      def type
        "OAuth#{version_one? && 'One' || 'Two'}#{oauth_model_constant}".constantize
      end
      
      def oauth_model_constant
        oauth_model.to_s.singularize.camelcase.constantize
      end

      def version_one?
        @version_one ||= oauth_model_constant.oauth_providers[params[:service]][:oauth_version] == 1
      end

      def parse_response
        if version_one?
          request_token = session[:request_token]
          access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
          @oauth.attributes = {:oauth_token => access_token.params[:oauth_token], :oauth_token_secret => access_token.params[:oauth_token_secret]}
        else
          access_token = @oauth.client.web_server.get_access_token(params[:code], :redirect_uri => oauth_settings[:callback].bind(self).call)
          @oauth.attributes = {:refresh_token => access_token.refresh_token, :access_token => access_token.token}
        end
      end

      def redirect
        if version_one?
          @request_token = @oauth.consumer.get_request_token(:oauth_callback => oauth_settings[:callback].bind(self).call)
          session[:request_token] = @request_token
          redirect_to @request_token.authorize_url
        else
          redirect_to @oauth.client.web_server.authorize_url(:redirect_uri => oauth_settings[:callback].bind(self).call)
        end
      end
    end
  end
end