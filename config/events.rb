WebsocketRails::EventMap.describe do
  namespace :game do 
    subscribe :attack,  :to => GameActionController, :with_method => :attack
    subscribe :join,    :to => GameActionController, :with_method => :join
    subscribe :move,    :to => GameActionController, :with_method => :move
    subscribe :no_move, :to => GameActionController, :with_method => :no_move
    subscribe :place,   :to => GameActionController, :with_method => :place
  end
end
