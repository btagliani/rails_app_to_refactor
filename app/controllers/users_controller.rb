# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    # TODO: Refactor into service objects
    # to extract the logic of user creation into a specific user creation service object
    # always returns a user object, even if the user is not valid
    user = UserCreationService.call(user_params)

    if user.valid? && user.save
      render_json(201, user: user.as_json(only: [:id, :name, :token]))
    else
      render_json(422, user: user.errors.as_json)
    end
  end

  def show
    perform_if_authenticated
  end

  def destroy
    perform_if_authenticated do
      current_user.destroy
    end
  end

  private

   # TODO: Create service object for user authentication
   # to extract the logic of user authentication into a specific user authentication service object
   # even though right now we dont have much logic to extract, it can grow in the future and we would benefit from it
    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end

  # TODO: Use strong parameters
  # to prevent mass assignment vulnerabilities, only require the parameters that we need to create the user
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
