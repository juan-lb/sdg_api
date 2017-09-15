class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  protected

  def authenticate
    authenticate_token || unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      token == ENV['AUTH_TOKEN']
    end
  end

  def unauthorized
    render json: { error: 'Bad credentials' }, status: :unauthorized
  end

  def bad_request
    render json: {
      error_type: @manager.error_type,
      errors:     @manager.errors
    }, status: 400
  end

end
