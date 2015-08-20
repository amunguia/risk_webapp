class Game < ActiveRecord::Base

  include Risk::Game::API

  attr_accessor :army_map, :assignment_map, :cards, :error_message, :players_map,
                :move_from, :move_to, :players, :state

  after_initialize do |game|
    game.army_map       = game.army_map_str ? eval(game.army_map_str) : {}
    game.assignment_map = game.assignment_map_str ? eval(game.assignment_map_str) : {}
    game.cards          = game.cards_str ? eval(game.cards_str) : {}
    game.move_from      = game.move_from_str ? game.move_from_str.to_sym : nil
    game.move_to        = game.move_to_str ? game.move_to_str.to_sym : nil
    game.players        = game.players_str ? eval(game.players_str) : []
    game.players_map    = game.players_map_str ? eval(game.players_map_str) : {}
    game.state          = game.state_id ? state_for_id : Risk::Game::InitialPlaceState.new
  end

  before_save do |game|
    game.army_map_str       = game.army_map ? game.army_map.inspect : "{}"
    game.assignment_map_str = game.assignment_map ? game.assignment_map.inspect : "{}"
    game.cards_str          = game.cards ? game.cards.inspect : "{}"
    game.move_from_str      = game.move_from ? game.move_from.to_s : nil
    game.move_to_str        = game.move_to ? game.move_to.to_s : nil
    game.players_str        = game.players ? game.players.inspect : "[]"
    game.players_map_str    = game.players_map ? game.players_map.inspect : "{}"
    game.state_id           = game.state ? id_for_state : 6 # improper initialize
  end

  def add_player(user)
    if players_map.keys.length < players.length &&
         players_map[user] == nil
      player_id            = players_map.keys.length + 1
      players_map[user] = {name: user, label: "player#{player_id}", player_id: player_id}
      players_map[user]
    else
      false
    end
  end

  def is_current_player(user)
    if players_map[user] && players_map[user][:player_id] == current_player
      players_map[user][:player_id]
    else
      false
    end
  end

  def filtered(player)
    {
      "army_map"       => army_map,
      "assignment_map" => assignment_map,
      "cards"          => player ? cards[player] :  [],  #only show current players cards, not all players cards
      "current_player" => find_current_player,
      "error"          => (current_player.eql? player) ? error_message : nil, #only show error message to current player
      "max_place"      => max_place,
      "minimum_move"   => minimum_move,
      "move_from"      => move_from,
      "move_to"        => move_to,
      "players"        => players,
      "state"          => id_for_state,
      "won"            => won
    }
  end


  def id_for_state
    if players_map.keys.length < players.length
      return 0
    end

    type = state.class.to_s
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
    when "Risk::Game::GameOverState"
      6
    else
      raise "Unknown State. Cannot retrieve id."
    end
  end

  def state_for_id
    case state_id
    when 1
      Risk::Game::AttackState.new
    when 0,2
      Risk::Game::InitialPlaceState.new
    when 3
      Risk::Game::PostAttackMoveState.new
    when 4
      Risk::Game::TurnStartAfterCardsState.new
    when 5
      Risk::Game::TurnStartState.new
    when 6
      Risk::Game::GameOverState.new
    else
      raise "State does not exists."
    end
  end

  private 

  def find_current_player
    players_map.each do |k,v|
      if v[:player_id] == current_player
        return k
      end
    end
    0
  end

end
