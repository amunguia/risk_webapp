class GameController < ApplicationController

  def new
    @game = Game.create_with_players initial_players
    @game.save
    redirect_to action: "show", id: @game.id
  end

  def players
    @game = Game.find params[:id]
    render json: @game.players_map.values
  end

  def index
    @games = Game.open_games
  end

  def show
    @game = Game.find params[:id]
    @user = current_user
    render "show"
  end

  def state
    @game = Game.find params[:id]
    @user = current_user
    render json: @game.filtered(current_user)
  end

  def use_cards
    @game = Game.find params[:id]
    by_user = @game.current_player
    cards = params[:cards].split(",")

    @game.use_cards(by_user, cards)
    WebsocketRails[:game].trigger 'message', @game.action_message
    @game.save
    render "show"
  end

  private 
  
  def initial_players
    players = []
    number  = params[:num] ? params[:num].to_i : 3
    number.times { |i| players << i+1 }
    players
  end

  def reset_players(game)
    players = []
    game.players.length.times {|i| players << 0}
    players
  end

end
