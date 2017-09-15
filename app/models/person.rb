class Person < SymfonyDatabase
  self.table_name = :persona_fisica

  NO_YEAR = 'Sin Informar'

  # -- Associations
  has_many :claim_persons, foreign_key: 'persona_fisica_id'
  has_many :claims, through: :claim_persons

  # -- Validations
  validates_presence_of :nombre, :apellido, :localidad_id, :sexo, :a_nacimiento, :nrodoc
  validate :validate_birth

  # -- Methods
  def gender
    %w[Masculino Femenino].index(self.sexo)
  end

  def document_type
    %w[DNI LE LC RI IR Pasaporte].index(self.tipodoc)
  end

  private

  def validate_birth
    return false unless a_nacimiento
    return true  if a_nacimiento == NO_YEAR

    if a_nacimiento == 'sin_informar'
      self.a_nacimiento = NO_YEAR
      return true
    end

    unless a_nacimiento.to_i.between? 1910, Date.today.year
      errors[:a_nacimiento] << "debe ser entre 1910 y #{Date.today.year}"
    end
  end

end
