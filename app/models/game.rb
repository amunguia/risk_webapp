class Game < ActiveRecord::Base

  include Risk::Game::API

  attr_accessor :army_map, :assignment_map, :cards, :error_message, :move_from, :move_to, :players, :state

  after_initialize do |game|
    game.army_map       = game.army_map_str ? eval(game.army_map_str) : {}
    game.assignment_map = game.assignment_map_str ? eval(game.assignment_map_str) : {}
    game.cards          = game.cards_str ? eval(game.cards_str) : {}
    game.move_from      = game.move_from_str ? game.move_from_str.to_sym : nil
    game.move_to        = game.move_to_str ? game.move_to_str.to_sym : nil
    game.players        = game.players_str ? eval(game.players_str) : []
    game.state          = game.state_id ? Game.state_for_id(game.state_id) : Risk::Game::InitialPlaceState.new
  end

  before_save do |game|
    game.army_map_str       = game.army_map ? game.army_map.inspect : "{}"
    game.assignment_map_str = game.assignment_map ? game.assignment_map.inspect : "{}"
    game.cards_str          = game.cards ? game.cards.inspect : "{}"
    game.move_from_str      = game.move_from ? game.move_from.to_s : nil
    game.move_to_str        = game.move_to ? game.move_to.to_s : nil
    game.players_str        = game.players ? game.players.inspect : "[]"
    game.state_id           = game.state ? Game.id_for_state(game.state) : 6 # improper initialize
  end

  def filtered(player)
    {
      "army_map"       => army_map,
      "assignment_map" => assignment_map,
      "cards"          => player ? cards[player] :  [],  #only show current players cards, not all players cards
      "error"          => (current_player.eql? player) ? error_message : nil, #only show error message to current player
      "max_place"      => max_place,
      "minimum_move"   => minimum_move,
      "move_from"      => move_from,
      "move_to"        => move_to,
      "players"        => players,
      "state"          => Game.id_for_state(state),
      "won"            => won
    }
  end


  def self.id_for_state(s)
    type = s.class.to_s
    case type
    when "Risk::Game::AttackState"
      1
    when "Risk::Game::InitialPlaceState"
      2
    when "Risk::Game::PostAttackMoveState"
      3
    when "Risk::Game::TurnStartAfterCardsState"
      4
    when "Risk::Game::TurnStartState"
      5
    when "Risk::Game::GameOver"
      6
    else
      raise "Unknown State. Cannot retrieve id."
    end
  end

  def self.state_for_id(id)
    case id
    when 1
      Risk::Game::AttackState.new
    when 2
      Risk::Game::InitialPlaceState.new
    when 3
      Risk::Game::PostAttackMoveState.new
    when 4
      Risk::Game::TurnStartAfterCardsState.new
    when 5
      Risk::Game::TurnStartState.new
    when 6
      Risk::Game::GameOver.new
    else
      raise "State does not exists."
    end
  end

end
