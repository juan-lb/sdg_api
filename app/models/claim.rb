class Claim < SymfonyDatabase

  self.table_name = :tramite

  # -- Associations
  has_many :claim_persons,
    foreign_key: 'tramite_id',
    primary_key: 'id'
  has_many :people, through: :claim_persons
  has_many :states, foreign_key: 'tramite_id', class_name: 'ClaimState'
  has_many :derivations, foreign_key: 'tramite_id', class_name: 'ClaimDerivation'

  # -- Validations
  validates_presence_of :direccion_actual_id, :usuario_ingreso_id, :fecha_inicio, :queja, :tipo_expediente_id, :tema_1_id

  # -- Methods
  def state
    states.last
  end

end
