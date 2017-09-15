class AttentionUpdater < TransactionManager

  attr_reader :attention, :observation

  def initialize(attention:, params:)
    @attention   = attention
    @params      = params
    @claim_was   = attention.tramite_id
    @channel_was = attention.canal_de_atencion
  end

  def call
    return false unless valid_claim? && user

    if attention.update(attention_params)
      update_observation
      send_email
      true
    else
      @error_type = Const::VALIDATION_ERROR
      @errors     = {atencion: attention.errors}
      false
    end

  rescue ActiveRecord::RecordNotFound
    @error_type = Const::VALIDATION_ERROR
    @errors     = Const::USER_NOT_FOUND_ERROR
  end

  private

  def valid_claim?
    return true unless @params[:claim_id]

    @claim ||= Claim.find(@params[:claim_id])

    if @claim.deleted_at.nil?
      true
    else
      raise ActiveRecord::RecordNotFound
    end

  rescue ActiveRecord::RecordNotFound
    @error_type = Const::VALIDATION_ERROR
    @errors     = Const::CLAIM_NOT_FOUND_ERROR
    false
  end

  def update_observation
    @observation = ClaimObservation.find_by(
      tramite_id:        @claim_was,
      atencion_id:       attention.id
    )

    @observation.requiere_contacto = attention.requiere_contacto

    if @claim_was != @claim.id
      @observation.tramite_id = @claim.id
    end

    if @channel_was != attention.canal_de_atencion
      @observation.observacion = "Conversación mantenida a través del canal: #{@params[:channel]}"
    end

    @observation.save
  end

  def send_email
    return unless attention.requiere_contacto

    to = nil

    if @claim.area_responsable_id
      to = Office.find(@claim.area_responsable_id).mail
    end

    to ||= Office.find(@claim.direccion_actual_id).mail

    to = @params[:test_email] if @params[:test_email]

    MailerManager.new(
      sender:          'Sistema de Gestión - Defensoría BA',
      sender_email:    'no-reply@snappler.com',
      subject:         'SDG - Atención requiere contacto posterior',
      recipients:      [to],
      template_name:   Const::MANDRILL_CONTACT_REQUIRED,
      template_params: {
        claim_id:     attention.tramite_id,
        email:        to,
        attention_id: attention.id,
        text:         Const::MANDRILL_CONTACT_REQUIRED_UPDATE_TEXT
      },
    ).call
  end

  def attention_params
    @attention_params ||= {
      fecha_inicio: @params[:start_date] || attention.fecha_inicio,
      titulo:       @params[:title]      || attention.titulo,
      tramite_id:   @claim.id            || attention.tramite_id,
      canal_de_atencion: @params[:channel] || attention.canal_de_atencion,
      requiere_contacto: @params[:contact_required].nil? ? attention.requiere_contacto : @params[:contact_required]
    }
  end

end
