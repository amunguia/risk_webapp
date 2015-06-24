class GameActionController < WebsocketRails::BaseController

  def attack
    game           = Game.find message[:game]
    attacker       = game.current_player
    attack_country = message[:attack_country].downcase.to_sym
    defend_country = message[:defend_country].downcase.to_sym
    attack_with    = message[:attack_with].to_i

    game.attack(attacker, attack_country, defend_country, attack_with)
    game.save

    update_players game
  end

  def move
    game                = Game.find message[:game]
    mover               = game.current_player
    destination_country = message[:destination_country].downcase.to_sym 
    source_country      = message[:source_country].downcase.to_sym
    number_armies       = message[:number_armies].to_i

    game.move(mover, source_country, destination_country, number_armies)
    game.save

    update_players game
  end

  def no_move
    game     = Game.find message[:game]
    no_mover = game.current_player

    game.no_move no_mover
    game.save

    update_players game
  end

  def place 
    game    = Game.find message[:game]
    placer  = game.current_player
    country = message[:country].to_sym
    armies  = message[:armies]

    game.place(placer, country, armies) 
    game.save

    update_players game
  end

  private 

  def update_players(game)
    WebsocketRails[:game].trigger 'state', game.filtered(game.current_player)

    if game.action_message
      WebsocketRails[:game].trigger 'message', game.action_message
    end
  end

end