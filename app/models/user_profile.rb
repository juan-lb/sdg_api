class UserProfile < SymfonyDatabase
  self.table_name = :sf_guard_user_profile

  def gender
    %w[Masculino Femenino].index(self.sexo)
  end
end
