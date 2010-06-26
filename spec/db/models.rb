class SimpleOauth < ActiveRecord::Base

  oauth do
    provider 'Someone' do
      key    'asdf'
      secret 'asdf'
      site   'https://www.google.com'
      authorize_path     'asdf'
      access_token_path  'asdf'
      request_token_path 'asdfff'
    end
    provider 'GitHub' do
      key    'asdf'
      secret 'asdf'
      site   'https://www.github.com'
      authorize_path    'asdf'
      access_token_path 'asdf'
    end
    provider 'Facebook' do
      key    'asdf'
      secret 'asdf'
      site   'https://www.facebook.com'
      authorize_path    'asdf'
      access_token_path 'asdf'
    end
  end

end

class User < ActiveRecord::Base
  
  has_many :simple_oauths, :dependent => :destroy, :as => :owner
  
  accepts_nested_attributes_for :simple_oauths
  
  with_options :unless => :using_sso? do |without_sso|
    without_sso.validates_presence_of :username, :password
    without_sso.validates_confirmation_of :password
  end
  
  def using_sso?
    !simple_oauths.empty?
  end
  
end