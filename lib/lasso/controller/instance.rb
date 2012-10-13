module Lasso
  module Controller
    module InstanceMethods
      def new
        @oauth = type.new(:service => params[:service])
        redirect
      end

      def create
        @owner = oauth_settings[:through].bind(self).call
        @oauth = type.new(:service => params[:service], :owner => @owner)
        parse_response
        if @oauth.duplicate
          if @owner.nil? || @owner.new_record?
            send(oauth_settings[:login], @oauth.duplicate.owner)
          elsif @owner == @oauth.duplicate.owner
            @oauth.duplicate.destroy
            save_the_oauth
          else
            send(oauth_settings[:conflict], @oauth.duplicate.owner)
          end
        else
          save_the_oauth
        end
      end

    protected
    
      def save_the_oauth
        nested = {"#{oauth_model}_attributes" => [@oauth.attributes]}
        @owner.update_attributes!(nested)
        redirect_to send("#{oauth_model.to_s.singularize}_path", @owner.send(oauth_model).last)
      end

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
          access_token = @oauth.client.auth_code.get_token(params[:code], :redirect_uri => oauth_settings[:callback].bind(self).call)
          @oauth.attributes = {:refresh_token => access_token.refresh_token, :access_token => access_token.token}
        end
      end

      def redirect
        if version_one?
          @request_token = @oauth.client.get_request_token(:oauth_callback => oauth_settings[:callback].bind(self).call)
          session[:request_token] = @request_token
          redirect_to @request_token.authorize_url
        else
          redirect_to @oauth.client.auth_code.authorize_url(:redirect_uri => oauth_settings[:callback].bind(self).call, :scope => oauth_model_constant.oauth_providers[params[:service]][:scopes])
        end
      end
    end
  end
end
