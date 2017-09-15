class SpecificThematic < SymfonyDatabase

  self.table_name = :tematica_especifica

  # -- Associations
  belongs_to :subthematic, foreign_key: 'subtematica_id'

end
