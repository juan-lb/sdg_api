class WrongClaimState < StandardError; end

class V1::ClaimsBaseController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from WrongClaimState, with: :invalid_state

  private

  def success(status = 200)
    render json: {
      tramite: @manager.claim,
      persona: @manager.person
    }, status: status
  end

  def not_found
    render json: {error: Const::CLAIM_NOT_FOUND_ERROR}, status: 404
  end

  def invalid_state(exception)
    render json: {error: exception.message}, status: 400
  end

end
