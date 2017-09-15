require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest

  def setup
		@token = "Token token=#{ENV['AUTH_TOKEN']}"
  end

  test 'should not succeed if has no token' do
    get '/v1/foo'

    assert_response :unauthorized
  end

  test 'should not succeed if token is invalid' do
    get '/v1/foo'

    assert_response :unauthorized
  end

  test 'should succeed if token is valid' do
    get '/v1/foo', headers: { HTTP_AUTHORIZATION: @token,
                              Accept: 'application/json' }

    assert_response :success
  end

end
