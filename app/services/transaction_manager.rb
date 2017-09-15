class TransactionManager

  attr_reader :errors, :error_type

  protected

  def user
    return @user if @user

    @user = User.find_by(username: @params[:username])
    @user = User.first if @user.nil? || @user.deleted_at

    @user
  end

  def user_profile
    @user_profile ||= UserProfile.find_by(user_id: user.id)
  end

end
