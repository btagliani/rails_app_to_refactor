# frozen_string_literal: true

class UserCreationService
  def self.call(user_params)
    new(user_params).call
  end

  def initialize(user_params)
    @user_params = user_params
  end

  def create
    # assume validations are done in User model and we return a user object always
    # can ve valid or invalid either way
    return password_validations unless password_validations.empty?

    user = User.new(
      name: user_params[:name],
      email: user_params[:email],
      token: SecureRandom.uuid,
      password_digest: password_digest
    )
  end

  private

  def password_digest
    Digest::SHA256.hexdigest(password)
  end

  def password_validations
    errors = {}
    errors[:password] = ["can't be blank"] if password.blank?
    errors[:password_confirmation] = ["doesn't match password"] if password != password_confirmation

    errors
  end
end
