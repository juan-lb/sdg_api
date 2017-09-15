class Subthematic < SymfonyDatabase

  self.table_name = :subtematica

  # -- Associations
  belongs_to :general_thematic, foreign_key: 'tematica_general_id'
  has_many :specific_thematics, foreign_key: 'subtematica_id'

end
