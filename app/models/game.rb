class Game < ActiveRecord::Base

  include Risk::Game::GameInterface

  def self.create_with_players(players)
    game = Game.new
    game.init
    game.set_players players
    game.players_to_setup = players.length

    players.each do |p|
      game.set_cards_for_player(p, [])
    end

    game.build_assignment_map
    game.state = Risk::Game::InitialPlaceState.new
    game
  end

  #def after_initialize
  #  self.init
  #  self.state = InitialPlaceState.new
  #end

  def army_map
    self.army_map_string ? eval(self.army_map_string) : {}
  end

  def army_map=(hash)
    self.army_map_string = hash.to_s
  end

  def assignment_map
    self.assignment_map_string ? eval(self.assignment_map_string) : {}
  end

  def assignment_map=(hash)
    self.assignment_map_string = hash.inspect
  end

  def cards
    self.cards_string ? eval(self.cards_string) : ""
  end

  def cards=(array)
    self.cards_string = array.inspect
  end

  def move_from
    self.move_from_string ? self.move_from_string.to_sym : ""
  end

  def move_from=(symbol)
    self.move_from_string = symbol.to_s
  end

  def move_to 
    self.move_to_string ? self.move_to_string.to_sym : ""
  end

  def move_to=(symbol)
    self.move_to_string = symbol.to_s
  end

  def players
    self.players_string ? eval(self.players_string) : []
  end

  def players=(array)
    self.players_string = array.inspect
  end

  def state
    state_for_id(self.state_id)
  end

  def state=(s)
    self.state_id = id_for_state(s)
  end

  private 

  def id_for_state(s)
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
    else
      raise "Unknown State. Cannot retrieve id."
    end
  end

  def state_for_id(id)
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
    else
      raise "State does not exists."
    end
  end

end
