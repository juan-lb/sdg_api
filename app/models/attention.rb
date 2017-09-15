class Attention < SymfonyDatabase

  self.table_name = :atencion

  # -- Associations
  belongs_to :claim, foreign_key: 'tramite_id', primary_key: 'id'

end
