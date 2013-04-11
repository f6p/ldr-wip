class UsersController < ApplicationController
  before_filter :generate_token,        :only => [:new, :create]
  before_filter :redirect_if_signed_in, :only => [:new, :create]

  def autocomplete
    render :json => items_for_autocomplete(User.registered.distinct(:nick), params[:term])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find params[:id]
  end

  def create
    @user = User.register session[:token_nick], session[:token_value], params[:user]

    if @user.save
      redirect_to @user, :notice => 'User was successfully created.'
      sign_in @user
    else
      render :action => 'new'
    end
  end

  def update
    @user = User.find params[:id]

    if @user.update_attributes params[:user]
      redirect_to @user, :notice => 'User was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  respond_to :html, :json

  def index
    @search = Side.search_standings  params[:search]
    @sides  = Side.ordered_standings params[:search]

    respond_with @sides
  end

  def show
    @user = User.registered.find params[:id]

    respond_with @user
  end
end
