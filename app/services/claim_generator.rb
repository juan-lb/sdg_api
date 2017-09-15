class ClaimGenerator < TransactionManager

  PERSON_ROLE = 'Denunciante'

  attr_reader :claim, :person

  def initialize(params:)
    @params = params
  end

  def call
    @claim = Claim.new(create_params)

    if claim.save
      claim.update numero_de_atencion: claim.id

      return false unless create_person

      create_state
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

  def create_person
    @person = Person.create(person_params)

    if person.valid?
      person.save

      ClaimPerson.create(
        tramite_id:        claim.id,
        persona_fisica_id: person.id,
        rol:               PERSON_ROLE
      )

      true
    else
      claim.destroy
      @error_type = Const::VALIDATION_ERROR
      @errors     = {persona: person.errors}
      false
    end

  end

  def create_state
    ClaimState.create(
      tramite_id:    claim.id,
      estado:        Const::CLAIM_INITIAL_STATUS,
      numero:        claim.numero_de_atencion,
      observaciones: Const::CLAIM_INITIAL_OBS,
      fecha:         Time.now,
      usuario_id:    user.id
    )
  end

  def create_params
    @claim_params ||= {
      direccion_actual_id:     user_profile.direccion_id,
      area_responsable:        '',
      usuario_ingreso_id:      user.id,
      fecha_inicio:            @params[:start_date] || Time.now,
      titulo:                  '',
      queja:                   @params[:complain],
      como_conocio_id:         @params[:how_he_met],
      tipo_expediente_id:      @params[:file_type_id] || user_profile.tipo_expediente_id,
      tema_1_id:               948,
      resuelto:                solved,
      #info_ar:                 '',
      id_consulta_crm:         @params[:crm_query_id],
      modulo_de_origen:        @params[:source_module],
      created_at:              Time.now
    }
  end

  def solved
    case @params[:source_module]
    when Const::CLAIM_SOURCE_MODULE[:cases]
      false
    when Const::CLAIM_SOURCE_MODULE[:digital], Const::CLAIM_SOURCE_MODULE[:face_to_face], Const::CLAIM_SOURCE_MODULE[:phone]
      true
    else
      false
    end
  end

  def person_params
    params = @params[:person]

    return {} unless params
    @person_params ||= {
      id_habitante_crm:     params[:crm_id],
      nombre:               params[:name],
      apellido:             params[:surname],
      localidad_id:         params[:location_id],
      sexo:                 params[:genre],
      a_nacimiento:         params[:birth_year],
      nrodoc:               params[:dni].blank? ? nil : params[:dni],
      fecha_nacimiento:     params[:birth],
      tel_fijo:             params[:tel],
      tel_movil:            params[:mobile],
      mail:                 params[:email],
      pais_id:              params[:country_id],
      cod_postal_cpa:       params[:postal_code],
      calle:                params[:street],
      numero:               params[:street_number],
      area:                 params[:area],
      ocupacion_id:         params[:profession_id],
      cuit:                 params[:cuit],
      cuil:                 params[:cuil],
      observaciones:        params[:observations],
      capacidade_diferente: params[:disabilities],
      nivel_educativo_id:   params[:education_level]
    }
  end

end
