require "test_birst_command"

class Test_add_user_to_space < Test::Unit::TestCase

  def setup
    BCConfig.read_config
    BCConfig.read_config(File.join(File.dirname(__FILE__),"../config_test.json"))
  end

  def teardown
  end

  def test_add_user_to_space

    test_options = BCConfig.options[:test][:test_add_user_to_space]

    client = Savon.client do
      wsdl BCConfig.options[:wsdl]
      endpoint BCConfig.options[:endpoint]
      convert_request_keys_to :none
      soap_version 1
      pretty_print_xml true
      filters [:password]
    end

    response = client.call(:login) do
      message username: BCConfig.options[:username], 
              password: Obfuscate.deobfuscate(BCConfig.options[:password])
    end

    auth_cookies = response.http.cookies
    token = response.hash[:envelope][:body][:login_response][:login_result]

    # Add valid user to space
    response = client.call(:add_user_to_space, cookies: auth_cookies) do
      message token: "#{token}", 
              userName: "#{test_options[:userName]}", 
              spaceID: "#{test_options[:spaceID]}", 
              hasAdmin: "false"
    end
    puts response.hash


    response = client.call(:logout, cookies: auth_cookies) do
      message token: "#{token}"
    end

  end

end


