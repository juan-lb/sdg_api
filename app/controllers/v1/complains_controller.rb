class V1::ComplainsController < V1::ClaimsBaseController

  before_action :set_complain
  before_action :validate_state

  def update
    @manager = ComplainManager.new(claim: @complain, params: params)
    @manager.call(action: :update) ? success : bad_request
  end

  private

  def set_complain
    @complain = Claim.find(params[:id])

    raise ActiveRecord::RecordNotFound unless @complain.deleted_at.nil?
  end

  def validate_state
    if @complain.state.estado != Const::CLAIM_COMPLAIN_STATUS
      raise WrongClaimState.new(Const::CLAIM_STATE_ERROR)
    end
  end

end
