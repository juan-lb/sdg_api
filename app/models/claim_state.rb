class ClaimState < SymfonyDatabase

  self.table_name = :estado_de_tramite

  # -- Associations
  belongs_to :claim,
    foreign_key: 'tramite_id',
    primary_key: 'id'

end
