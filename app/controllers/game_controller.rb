class GameController < ApplicationController

  def attack
    @game = Game.find(params[:id])

    attacker = @game.current_player
    attack_country = params[:attack_country].downcase.to_sym
    defend_country = params[:defend_country].downcase.to_sym
    defender = @game.owner_of(defend_country)
    attack_with = params[:attack_with].to_i

    action = Risk::Game::AttackAction.new(attacker, defender, attack_country, defend_country, attack_with)

    @game = run(action, @game)

    render "show"
  end

  def move
    @game = Game.find(params[:id])

    destination_country = params[:destination_country].downcase.to_sym 
    source_country = params[:source_country].downcase.to_sym
    number_armies = params[:number_armies].to_i

    if (@game.state.class.eql? "Risk::Game::PostWinAttackState")
      action = Risk::Game::MoveAfterWinAction.new(source_country, destination_country, number_armies) 
    else 
      action = Risk::Game::MoveAction.new(source_country, destination_country, number_armies)
    end
    @game = run(action, @game)

    render "show"
  end

  def new
    @game = Game.create_with_players [1,2,3]
    @game.save
    render "show"
  end

  def no_move
    @game = Game.find(params[:id])
    action = Risk::Game::NoMoveAction.new

    @game = run(action, @game)

    render "show"
  end

  def place
    country = params[:country].downcase.to_sym
    number = params[:number].to_i

    @game = Game.find(params[:id].to_i)
    action = Risk::Game::PlaceAction.new(@game.current_player, country, number)

    run(action, @game)

    render "show"
  end

  def show
    @game = Game.find params[:id]
    render "show"
  end

  def use_cards
    @game = Game.find params[:id]

    by_user = @game.current_player
    cards = params[:cards].split(",")

    action = Risk::Game::UseCardsAction.new(by_user, cards)

    run(action, @game)

    render "show"
  end

  private 

  def run(action, game)
    if game.play_action(action, game)
      game.save
    else
      @error = "Invalid action."
    end
    game.save
    game
  end
  
end
