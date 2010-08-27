class UsersController < ApplicationController
  include TinyCore::Controllers::Users
  
  def show
    @user = User.find(params[:id])
    can_see_profile!(@user) do
      @comments = @user.latest_comments_for_user(current_user, :limit => 5)
      @comments_count = @user.comments_count_for_user(current_user)
    end
  end
end
