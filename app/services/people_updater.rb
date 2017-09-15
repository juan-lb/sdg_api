class PeopleUpdater < TransactionManager

  attr_reader :people

  def initialize(params:)
    @params = params
    set_people
  end

  def call
    if people.empty?
      @error_type = Const::VALIDATION_ERROR
      @errors     = Const::PERSON_NOT_FOUND
      return false
    end

    return false unless valid_person_params?

    if update_people
      true
    else
      @error_type = Const::VALIDATION_ERROR
      @errors     = {persona: 'Error al actualizar registros.'}
    end
  end

  private

  def set_people
    @people_to_update = []

    @people_to_update << Person.
      where(id_habitante_crm: @params[:id]).
      joins(:claims).
      where(tramite: {resuelto: false})

    @people_to_update << Person.
      where(id_habitante_crm: @params[:id]).
      joins(:claims => :derivations).
      where(tramite: {resuelto: true}).
      where('tramite_derivado.fecha >= ?', Date.today - 14.days)

    @people = @people_to_update[0] + @people_to_update[1]
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

  def update_people
    results = []

    results << @people_to_update[0].update_all(person_params)
    results << @people_to_update[1].update_all(person_params)

    results.all?
  end

  def person_params
    person = people.first

    @person_params ||= {
      nombre:               @params[:name]            || person.nombre,
      apellido:             @params[:surname]         || person.apellido,
      localidad_id:         @params[:location_id]     || person.location_id,
      sexo:                 @params[:genre]           || person.sexo,
      a_nacimiento:         @params[:birth_year]      || person.a_nacimiento,
      nrodoc:               @params[:dni]             || person.nrodoc,
      fecha_nacimiento:     @params[:birth]           || person.fecha_nacimiento,
      tel_fijo:             @params[:tel]             || person.tel_fijo,
      tel_movil:            @params[:mobile]          || person.tel_movil,
      mail:                 @params[:email]           || person.mail,
      pais_id:              @params[:country_id]      || person.pais_id,
      cod_postal_cpa:       @params[:postal_code]     || person.cod_postal_cpa,
      calle:                @params[:street]          || person.calle,
      numero:               @params[:street_number]   || person.numero,
      area:                 @params[:area]            || person.area,
      ocupacion_id:         @params[:profession_id]   || person.ocupacion_id,
      cuit:                 @params[:cuit]            || person.cuit,
      cuil:                 @params[:cuil]            || person.cuil,
      observaciones:        @params[:observations]    || person.observaciones,
      capacidade_diferente: @params[:disabilities]    || person.capacidade_diferente,
      nivel_educativo_id:   @params[:education_level] || person.nivel_educativo_id
    }
  end

end
