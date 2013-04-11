require 'bot'

class TokensController < ApplicationController
  before_filter :generate_token
  before_filter :redirect_if_signed_in

  def show
    nick  = params[:nick]
    token = session[:token_value]

    @status, @message = Bot::Token.new(nick, token).deliver
    session[:token_nick] = params[:nick] if @status

    respond_to do |format|
      format.html { render :text => @message }
      format.js
    end
  end
end
