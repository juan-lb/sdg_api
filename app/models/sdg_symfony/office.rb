class Office < SymfonyDatabase
  self.table_name = :direccion

  belongs_to :secretary, foreign_key: 'secretaria_id'
end
