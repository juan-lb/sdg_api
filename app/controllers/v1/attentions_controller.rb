class V1::AttentionsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :set_attention, only: [:update]

  def create
    @manager = AttentionGenerator.new(params: params)
    @manager.call ? success(201) : bad_request
  end

  def update
    @manager = AttentionUpdater.new(attention: @attention, params: params)
    @manager.call ? success : bad_request
  end

  private

  def set_attention
    @attention = Attention.find(params[:id])
  end

  def success(status = 200)
    render json: {
      atencion:    @manager.attention,
      observacion: @manager.observation
    }, status: status
  end

  def not_found
    render json: {error: Const::ATTENTION_NOT_FOUND_ERROR}, status: 404
  end

end
