class GeneralThematic < SymfonyDatabase

  self.table_name = :tematica_general

  # -- Associations
  has_many :subthematics, foreign_key: 'tematica_general_id'

end
