class GameActionController < WebsocketRails::BaseController

  def attack
    @game          = Game.find(message[:game])
    attacker       = @game.current_player
    attack_country = message[:attack_country].downcase.to_sym
    defend_country = message[:defend_country].downcase.to_sym
    attack_with    = message[:attack_with].to_i

    @game.attack(attacker, attack_country, defend_country, attack_with)
    @game.save

    WebsocketRails[:game].trigger 'state', @game.filtered(attacker)
  end

end