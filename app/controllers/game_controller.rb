class GameController < ApplicationController

  def attack
    @game = Game.find(params[:id])
    attacker = @game.current_player
    attack_country = params[:attack_country].downcase.to_sym
    defend_country = params[:defend_country].downcase.to_sym
    attack_with = params[:attack_with].to_i

    @game.attack(attacker, attack_country, defend_country, attack_with)
    @game.save

    WebsocketRails[:game].trigger 'state', @game.filtered(attacker)
    WebsocketRails[:game].trigger 'message', @game.action_messagebu
    render "show"
  end

  def move
    WebsocketRails[:game].trigger 'message', 'received something'
    @game = Game.find(params[:id])
    destination_country = params[:destination_country].downcase.to_sym 
    source_country = params[:source_country].downcase.to_sym
    number_armies = params[:number_armies].to_i

    @game.move(@game.current_player, source_country, destination_country, number_armies)
    @game.save

    WebsocketRails[:game].trigger 'state', @game.filtered(@game.current_player)
    WebsocketRails[:game].trigger 'message', @game.action_message
    render "show"
  end

  def new
    @game = Game.create_with_players [1,2,3]
    @game.save
    render "show"
  end

  def no_move
    @game = Game.find(params[:id]) 

    @game.no_move(@game.current_player)
    @game.save

    WebsocketRails[:game].trigger 'state', @game.filtered(@game.current_player)
    WebsocketRails[:game].trigger 'message', "ended turn"
    render "show"
  end

  def place
    @game = Game.find(params[:id].to_i)
    country = params[:country].downcase.to_sym
    number = params[:number].to_i

    @game.place(@game.current_player, country, number)
    @game.save

    WebsocketRails[:game].trigger 'state', @game.filtered(@game.current_player)
    WebsocketRails[:game].trigger 'message', @game.action_message
    render "show"
  end

  def show
    @game = Game.find params[:id]
    render "show"
  end

  def state
    @game = Game.find params[:id]
    render json: @game.filtered(1)
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
  
end
