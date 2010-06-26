class ApplicationController < ActionController::Base
  
  helper_method :current_user
  
  def current_user
    @mock_user ||= mock(User, :id => 1, :login => 'someone')
    User.stub!('find').with(1).and_return(@mock_user)
  end
  
end

class SimpleOauthsController < ApplicationController
  
  processes_oauth_transactions_for :simple_oauths, 
                                   :through  => lambda { current_user }, 
                                   :callback => lambda { "https://localhost/#{params[:service]}/callback" }
  
end

class OauthRegistrationController < ApplicationController
  
  processes_oauth_transactions_for :simple_oauths, 
                                   :through  => lambda { User.new },
                                   :callback => lambda { "https://localhost/#{params[:service]}/callback" }
  
end