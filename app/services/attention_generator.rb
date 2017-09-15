class AttentionGenerator < TransactionManager

  attr_reader :attention, :observation

  def initialize(params:)
    @params = params
  end

  def call
    return false unless valid_claim? && user

    @attention = Attention.new(attention_params)

    if attention.save
      create_observation
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
    false
  end

  private

  def valid_claim?
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

  def create_observation
    @observation = ClaimObservation.create(
      tramite_id:        @claim.id,
      usuario_id:        user.id,
      direccion_id:      user_profile.direccion_id,
      atencion_id:       attention.id,
      requiere_contacto: attention.requiere_contacto,
      observacion:       "Conversación mantenida a través del canal: #{@params[:channel]}",
      destacada:         false
    )
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
        text:         Const::MANDRILL_CONTACT_REQUIRED_CREATE_TEXT
      },
    ).call
  end

  def attention_params
    @attention_params ||= {
      fecha_inicio:      @params[:start_date]       || Time.now,
      titulo:            @params[:title],
      requiere_contacto: @params[:contact_required] || false,
      canal_de_atencion: @params[:channel],
      usuario_crm:       @params[:crm_user],
      id_consulta_crm:   @params[:crm_query_id],
      tramite_id:        @claim.id
    }
  end

end
