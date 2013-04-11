class RatingsController < ApplicationController
  def index
    @user = User.registered.find params[:user_id]

    respond_to do |format|
      format.json { render :json => @user.ratings }
    end
  end
end
