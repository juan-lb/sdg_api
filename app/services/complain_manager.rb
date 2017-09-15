class ComplainManager < TransactionManager

  attr_reader :claim, :person

  def initialize(claim:, params:)
    @params = params
    @claim  = claim
    @person = claim.claim_persons.
      where(rol: ClaimGenerator::PERSON_ROLE).
      take.
      person

    @claim_was  = claim.attributes
    @person_was = person.attributes

    @validator = ComplainValidator.new(
      claim_params:  claim_params,
      person_params: person_params
    )
  end

  def call(action: :create)
    return false unless valid_params? && valid_thematics? && user

    if claim.update(claim_params)
      person.update(person_params)

      if action == :create
        generate_state
        generate_derivated_claim
      end

      generate_observations if changes.any?
      true
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

  def valid_params?
    if @validator.call
      true
    else
      @error_type = Const::VALIDATION_ERROR
      @errors     = @validator.errors
      false
    end
  end

  def valid_thematics?
    thematic    = GeneralThematic.find(@params[:general_thematic_id])
    subthematic = Subthematic.find(@params[:subthematic_id])
    specific    = SpecificThematic.find(@params[:specific_thematic_id])

    conditions = [
      thematic.subthematics.include?(subthematic),
      subthematic.specific_thematics.include?(specific)
    ]

    if conditions.all?
      true
    else
      @error_type = Const::VALIDATION_ERROR
      @errors     = Const::THEMATIC_COMB_ERROR
      false
    end

  rescue ActiveRecord::RecordNotFound
    @error_type = Const::VALIDATION_ERROR
    @errors     = Const::THEMATIC_NOT_FOUND
    false
  end

  def generate_state
    ClaimState.create(
      tramite_id:    claim.id,
      estado:        Const::CLAIM_COMPLAIN_STATUS,
      numero:        claim.numero_de_atencion,
      caratula:      claim.titulo,
      observaciones: Const::CLAIM_COMPLAIN_OBS,
      fecha:         Time.now,
      usuario_id:    user.id
    )
  end

  def generate_derivated_claim
    ClaimDerivation.create(
      tramite_id:           claim.id,
      direccion_origen_id:  @claim_was['direccion_actual_id'],
      direccion_destino_id: 10,
      estado:               'Aceptado',
      fecha:                Time.now,
      fecha_accion:         nil,
      fecha_plazo:          nil,
      texto:                "Tramite autoderivado desde la oficina: #{Office.find(@claim_was['direccion_actual_id']).nombre}",
      prioridad:            'normal',
      usuario_id:           user.id
    )
  end

  def generate_observations
    ClaimObservation.create(
      tramite_id:   claim.id,
      usuario_id:   user.id,
      direccion_id: user_profile.direccion_id,
      observacion:  "Se han modificado los campos: #{changes.join(' - ')} - del Formulario de contacto.",
      destacada:    false
    )

    ClaimObservation.create(
      tramite_id:   claim.id,
      usuario_id:   user.id,
      direccion_id: user_profile.direccion_id,
      observacion:  new_responsible_area_observation,
      destacada:    false
    ) if @claim_was['area_responsable_id'] != claim.area_responsable_id
  end

  def new_responsible_area_observation
    user_name = "#{user.last_name}, #{user.first_name} (#{user.username})"
    if claim.area_responsable_id
      area = Office.find(claim.area_responsable_id)
      code = area.codigo
      name = area.nombre
    else
      code = '-'
      name = '-'
    end

    "Se ha modificado el área responsable por el usuario: #{user_name}. El nuevo área responsable es: #{code} - #{name}"
  end

  def changes
    return @changes if @changes

    @changes = []
    @changes += (claim.attributes.except('updated_at').to_a - @claim_was.to_a).map(&:first)
    @changes += (person.attributes.except('updated_at').to_a - @person_was.to_a).map(&:first)

    @changes
  end

  def claim_params
    @claim_params ||= {
      direccion_actual_id: 10,
      fecha_inicio:        @params[:start_date]          || claim.fecha_inicio,
      queja:               @params[:complain]            || claim.queja,
      como_conocio_id:     @params[:how_he_met]          || claim.como_conocio_id,
      area_responsable_id: @params[:responsible_area_id] || claim.area_responsable_id,
      titulo:              @params[:title]               || claim.titulo,
      tipo_expediente_id:  @params[:file_type_id]        || claim.tipo_expediente_id,
      #tema_1_id:           @params[:subject_one]         || claim.tema_1_id,
      fecha_ocurrido:      @params[:happening_date]      || claim.fecha_ocurrido,
      pronta_atencion:     @params[:urgent_care]         || claim.pronta_atencion,
      created_at:          @params[:created_at]          || claim.created_at,
      organismo_denunciado_id: @params[:demanded_institution] || claim.organismo_denunciado_id,
      tematica_general_id:    @params[:general_thematic_id]  || claim.tematica_general_id,
      subtematica_id:         @params[:subthematic_id]       || claim.subtematica_id,
      tematica_especifica_id: @params[:specific_thematic_id] || claim.tematica_especifica_id,
      resuelto:            false
    }
  end

  def person_params
    params = @params[:person]

    return {} unless params
    @person_params ||= {
      nombre:       params[:name]          || person.nombre,
      apellido:     params[:surname]       || person.apellido,
      a_nacimiento: params[:birth_year]    || person.a_nacimiento,
      pais_id:      params[:country_id]    || person.pais_id,
      localidad_id: params[:location_id]   || person.localidad_id,
      sexo:         params[:genre]         || person.sexo,
      tel_fijo:     params[:tel]           || person.tel_fijo,
      tel_movil:    params[:mobile]        || person.tel_movil,
      calle:        params[:street]        || person.calle,
      numero:       params[:street_number] || person.numero,
      ocupacion_id: params[:profession_id] || person.ocupacion_id,
      nrodoc:       params[:dni].blank? ? nil : params[:dni] || person.nrodoc,
      nivel_educativo_id: params[:education_level] || person.nivel_educativo_id
    }
  end

end


class ComplainValidator

  COMPLAIN_ERROR    = 'Queja no puede estar en blanco'
  SUBJECT_ONE_ERROR = 'El tema 1 debe diferir de 948'

  attr_reader :errors

  def initialize(claim_params:, person_params:)
    @claim_params  = claim_params
    @person_params = person_params
    @errors        = {}
  end

  def call
    claim_validation  = valid_claim?
    person_validation = valid_person?

    claim_validation && person_validation
  end

  private

  def valid_claim?
    errors = {}

    if @claim_params[:queja].blank?
      errors[:queja] = COMPLAIN_ERROR
    end

    #if @claim_params[:tema_1_id].to_i == 948
      #errors[:tema_1] = SUBJECT_ONE_ERROR
    #end

    if errors.empty?
      true
    else
      @errors[:tramite] = errors
      false
    end
  end

  def valid_person?
    validator = Person.new(@person_params)

    if validator.valid?
      true
    else
      @errors[:persona] = validator.errors
      false
    end
  end

end
