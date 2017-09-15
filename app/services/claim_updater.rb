class ClaimUpdater < TransactionManager

  attr_reader :claim, :person

  def initialize(claim:, params:)
    @params = params
    @claim  = claim
    @person = claim.claim_persons.
      where(rol: ClaimGenerator::PERSON_ROLE).
      take.
      person
  end

  def call
    return false unless valid_claim_state? &&
      valid_person_params? &&
      user

    if update_claim
      person.update(person_params)
    else
      @error_type = Const::VALIDATION_ERROR
      @errors     = {tramite: claim.errors}
      false
    end

  rescue ActiveRecord::RecordNotFound
    @error_type = Const::VALIDATION_ERROR
    @errors     = Const::USER_NOT_FOUND_ERROR
    false
  end

  private

  def valid_claim_state?
    if claim.state.estado != Const::CLAIM_INITIAL_STATUS
      @error_type = Const::VALIDATION_ERROR
      @errors     = {tramite: Const::CLAIM_STATE_ERROR}
      false
    else
      true
    end
  end

  def valid_person_params?
    validator = Person.new(person_params)

    if validator.valid?
      true
    else
      @error_type = Const::VALIDATION_ERROR
      @errors     = {persona: validator.errors}
      false
    end
  end

  def update_claim
    @changes = []

    if @params[:complain] != claim.queja
      claim.queja = @params[:complain]
      @changes << 'queja'
    end

    if @params[:how_he_met] != claim.como_conocio_id
      claim.como_conocio_id = @params[:how_he_met]
      @changes << 'como_conocio_id'
    end

    if @params[:file_type_id] != claim.tipo_expediente_id
      claim.tipo_expediente_id = @params[:file_type_id]
      @changes << 'tipo de expediente'
    end

    return true if @changes.empty?
    return false unless claim.save

    generate_observation

    true
  end

  def generate_observation
    ClaimObservation.create(
      tramite_id:   claim.id,
      usuario_id:   user.id,
      direccion_id: user_profile.direccion_id,
      observacion:  observation,
      destacada:    false
    )
  end

  def observation
    "Se ha modificado los campos: #{@changes.join(' - ')} - del Formulario de contacto."
  end

  def person_params
    params = @params[:person]

    return {} unless params
    @person_params ||= {
      nombre:       params[:name]        || person.nombre,
      apellido:     params[:surname]     || person.apellido,
      nrodoc:       params[:dni]         || person.nrodoc,
      a_nacimiento: params[:birth_year]  || person.a_nacimiento,
      sexo:         params[:genre]       || person.sexo,
      localidad_id: params[:location_id] || person.localidad_id,
      tel_fijo:     params[:tel]         || person.tel_fijo,
      tel_movil:    params[:mobile]      || person.tel_movil
    }
  end

end
