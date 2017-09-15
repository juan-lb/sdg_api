class ClaimPerson < SymfonyDatabase

  self.table_name   = :tramite_persona_fisica
  self.primary_keys =  [:tramite_id, :persona_fisica_id]

  # -- Associations
  belongs_to :claim, foreign_key: 'tramite_id'
  belongs_to :person, foreign_key: 'persona_fisica_id'

  # -- Validations
  validates_presence_of :tramite_id, :persona_fisica_id

end
