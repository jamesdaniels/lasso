require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Test extension
[SimpleOauth, SimpleOauthsController, OauthRegistrationController, ActiveRecord::Base, ActionController::Base].each do |klass|
  describe klass do
    it 'should extend out module' do
      klass.is_a?(Lasso).should be_true
    end   
    [:processes_oauth_transactions_for, :oauth].each do |method|
      it "should respond to #{method}" do
        klass.respond_to?(method).should be_true
      end
    end
  end
end

{SimpleOauth => :model, SimpleOauthsController => :controller, OauthRegistrationController => :controller}.each do |klass, type|
  describe klass do
    {
      Lasso::Model => (type == :model), 
      Lasso::Model::InstanceMethods => (type == :model),
      Lasso::Controller => (type == :controller),
      Lasso::Controller::InstanceMethods => (type == :controller)
    }.each do |included, truthiness|
      it "should #{truthiness && '' || 'not '}include #{included}" do
        klass.include?(included).should eql(truthiness)
      end
    end
    {
      Lasso::Model::Settings => (type == :model),
      Lasso::Controller::Settings => (type == :controller)
    }.each do |extended, truthiness|
      it "should #{truthiness && '' || 'not '}extend #{extended}" do
        klass.is_a?(extended).should eql(truthiness)
      end
    end
  end
end

describe SimpleOauth do
  describe 'Settings' do 
    describe 'Existing' do
      it 'should have a GitHub provider' do
        SimpleOauth.oauth_providers['GitHub'].blank?.should be_false
      end
      it 'should have a Facebook provider' do
        SimpleOauth.oauth_providers['Facebook'].blank?.should be_false
      end
      it 'should have a Someone provider' do
        SimpleOauth.oauth_providers['Someone'].blank?.should be_false
      end
      it 'should have the right GitHub settings' do 
        SimpleOauth.oauth_providers['GitHub'].should eql({:key => 'asdf', :secret => 'asdf', :site => 'https://www.github.com', :authorize_path => 'asdf', :access_token_path => 'asdf', :oauth_version => 2})
      end
      it 'should have the right Facebook settings' do
        SimpleOauth.oauth_providers['Facebook'].should eql({:key => 'asdf', :secret => 'asdf', :site => 'https://www.facebook.com', :authorize_path => 'asdf', :access_token_path => 'asdf', :oauth_version => 2})
      end
      it 'should have the right Someone settings' do
        SimpleOauth.oauth_providers['Someone'].should eql({:key => 'asdf', :secret => 'asdf', :site => 'https://www.google.com', :authorize_path => 'asdf', :access_token_path => 'asdf', :oauth_version => 1,  :request_token_path=>"asdfff"})
      end
    end
    describe 'New' do
      Settings = {:key => 'asdf', :secret => 'asdf', :site => 'https://www.google.com', :authorize_path => 'asdf', :access_token_path => 'asdf', :oauth_version => 1,  :request_token_path=>"asdfff"}
      it 'should be able to add a new provider' do
        SimpleOauth.class_eval do 
          oauth do
            provider 'ASDF' do 
              key Settings[:key]
              secret Settings[:secret]
              site Settings[:site]
              authorize_path Settings[:authorize_path]
              access_token_path Settings[:access_token_path]
              request_token_path Settings[:request_token_path]
            end
          end
        end
      end
      it 'should have the proper settings' do
        SimpleOauth.oauth_providers['ASDF'].should eql(Settings)
      end
      Lasso::Model::Settings::RequiredSettings.each do |required_key|
        it "should require #{required_key} be set" do
          lambda {
            SimpleOauth.class_eval do
              oauth do
                provider 'ASDF' do
                  key Settings[:key] unless required_key == :key
                  secret Settings[:secret] unless required_key == :secret
                  site Settings[:site] unless required_key == :site
                  authorize_path Settings[:authorize_path] unless required_key == :authorize_path
                  access_token_path Settings[:access_token_path] unless required_key == :access_token_path
                  request_token_path Settings[:request_token_path] unless required_key == :request_token_path
                end
              end
            end
          }.should raise_error(ArgumentError)
        end
        it "should require #{required_key} to have a non-empty value" do
          lambda {
            settings = Settings.merge(required_key => '')
            SimpleOauth.class_eval do
              oauth do
                provider 'ASDF' do
                  key settings[:key]
                  secret settings[:secret]
                  site settings[:site]
                  authorize_path settings[:authorize_path]
                  access_token_path settings[:access_token_path]
                  request_token_path settings[:request_token_path]
                end
              end
            end
          }.should raise_error(ArgumentError)
        end
      end
    end
  end
end

describe User do
  it 'should require password/username without sso' do
    User.new.should_not be_valid
  end
  it 'should work with nested attributes' do
    (user = User.new(:simple_oauths_attributes => [{ :token_a => 'asdf', :token_b => 'adsf', :service => 'GitHub' }])).should be_valid
    user.save!
    user.reload
    user.simple_oauths.empty?.should be_false
    user.simple_oauths.first.class.should eql(OAuthTwoSimpleOauth)
  end
end

describe SimpleOauthsController do
  describe 'Settings' do 
    describe 'Existing' do
      it 'should have an oauth_model' do
        SimpleOauthsController.oauth_model.should eql(:simple_oauths)
      end
    end
  end
end