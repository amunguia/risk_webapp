class GameActionController < WebsocketRails::BaseController

  def attack
    game           = Game.find message[:game]
    attacker       = game.is_current_player current_user
    attack_country = message[:attack_country].downcase.to_sym
    defend_country = message[:defend_country].downcase.to_sym
    attack_with    = message[:attack_with].to_i

    if attacker
      game.attack(attacker, attack_country, defend_country, attack_with)
      game.save

      update_players game
    end
  end

  def join
    game      = Game.find message[:game]
    username  = message[:username]
    joined    = game.add_player(current_user, username)
    if joined
      game.save
      WebsocketRails["game#{game.id}"].trigger 'users', joined
      update_players game
    else
      WebsocketRails["game#{game.id}"].trigger 'state', {error: "Sorry, that username is take. Please choose another."}
    end
  end

  def move
    game                = Game.find message[:game]
    mover               = game.is_current_player current_user
    destination_country = message[:destination_country].downcase.to_sym 
    source_country      = message[:source_country].downcase.to_sym
    number_armies       = message[:number_armies].to_i

    if mover 
      game.move(mover, source_country, destination_country, number_armies)
      game.save

      update_players game
    end
  end

  def no_move
    game     = Game.find message[:game]
    no_mover = game.is_current_player current_user

    if no_mover
      game.no_move game.current_player
      game.save

      update_players game
    end
  end

  def place 
    game    = Game.find message[:game]
    placer  = game.is_current_player current_user
    country = message[:country].to_sym
    armies  = message[:armies]

    if placer 
      game.place(game.current_player, country, armies) 
      game.save

      update_players game
    end
  end

  private 

  def current_user
    if session[:user_id] == nil
      session[:user_id] = rand(36**8).to_s(36)
    else
      session[:user_id]
    end
  end

  def update_players(game)
    WebsocketRails["game#{game.id}"].trigger 'state', game.filtered(game.current_player)

    if game.action_message
      WebsocketRails["game#{game.id}"].trigger 'message', game.action_message
    end
  end

end