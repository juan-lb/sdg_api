class V1::ClaimsController < V1::ClaimsBaseController

  before_action :set_claim, only: [:show, :update, :change_to_complain, :add_file]
  before_action :validate_state, only: [:update, :change_to_complain]

  def show
    render json: @claim, status: 200
  end

  def create
    @manager = ClaimGenerator.new(params: params)
    @manager.call ? success(201) : bad_request
  end

  def update
    @manager = ClaimUpdater.new(claim: @claim, params: params)
    @manager.call ? success : bad_request
  end

  def change_to_complain
    @manager = ComplainManager.new(claim: @claim, params: params)
    @manager.call ? success : bad_request
  end

  def add_file
    @manager = FileUploader.new(claim: @claim, params: params)

    if @manager.call
      render json: {
        claim: @manager.claim,
        file:  @manager.file
      }, status: 201
    else
      bad_request
    end
  end

  private

  def set_claim
    @claim = Claim.find(params[:id])

    raise ActiveRecord::RecordNotFound unless @claim.deleted_at.nil?
  end

  def validate_state
    if @claim.state.estado != Const::CLAIM_INITIAL_STATUS
      raise WrongClaimState.new(Const::CLAIM_STATE_ERROR)
    end
  end

end
