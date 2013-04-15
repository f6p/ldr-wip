require 'archive'
require 'open-uri'
require 'replay'

class GamesController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create, :parse, :revoke]

  def autocomplete_map
    render :json => items_for_autocomplete(Game.distinct(:map), params[:term])
  end

  def autocomplete_faction
    render :json => items_for_autocomplete(Side.distinct(:faction), params[:term])
  end

  def autocomplete_leader
    render :json => items_for_autocomplete(Side.distinct(:leader), params[:term])
  end

  def new
    @game = Game.new
  end

  def create
    return cancel_report nil if params[:against].empty?

    if url? params[:against]
      replay = Replay::LadderGame.new params[:against].strip rescue return cancel_report 'Replay could not be downloaded.'
      @game  = Game.report_replay params[:result], current_user, replay
    else
      against = User.find_registered params[:against].strip rescue return cancel_report 'Can not report vs unregistered player.'
      @game   = Game.report params[:result], current_user, against
    end

    unless @game.new_record?
      redirect_to @game, :notice => 'Game was successfully reported.'
    else
      render :action => 'new'
    end
  end

  def download
    @game = Game.find params[:id]

    begin
      send_replay @game
    rescue
      redirect_to @game, :alert => 'Replay could not be downloaded.'
    end
  end

  def parse
    @game  = Game.find params[:id]
    authorize! :parse, @game

    begin
      @game.apply Replay::LadderGame.new params[:replay]
      redirect_to @game, :notice => 'Replay was successfully processed.'
    rescue
      redirect_to @game, :alert => 'Replay could not be processed.'
    end
  end

  def revoke
    @game = Game.find params[:id]
    authorize! :revoke, @game

    @game.revoke current_user
    redirect_to @game, :notice => 'Game was successfully revoked.'
  end

  def suggestions
    @games = suggestions_for 15.minutes.ago

    respond_to do |format|
      format.html { render :layout => false }
      format.json { render :json => @games.collect(&:link) }
    end
  end

  respond_to :html, :json

  def index
    respond_to do |format|
      format.atom do
        @games = Game.paginate :page => 1
      end

      format.any do
        @search = Game.search params[:search]
        @games  = @search.paginate :page => params[:page]

        respond_with @games
      end
    end
  end

  def show
    @game = Game.find params[:id]

    @commentable = @game
    @comment = Comment.new

    respond_with @game
  end

  private

  def cancel_report alert
    redirect_to new_game_path, :alert => alert
  end

  def get_archives datetime
    Archive::Games.new(datetime).read.list
  rescue
    Array.new
  end

  def send_replay game
    send_data open(game.replay).read, :filename => game.filename
    game.increase_downloads
  end

  def suggestions_for datetime
    suggestions = get_archives(datetime) + get_archives(datetime - 1.day)

    suggestions = suggestions.select do |game|
      allow = ['rby_side']
      allow << current_user.nick.downcase if user_signed_in?

      (game.players & allow).size > 0
    end

    suggestions[0, 25]
  end

  def url? param
    param.match /^http:\/\//
  end
end
