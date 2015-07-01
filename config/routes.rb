Rails.application.routes.draw do
  devise_for :users
  root "game#new"
  get  "game/new"           => "game#new"
  get  "game/:id"           => "game#show"
  post "game/:id/attack"    => "game#attack"
  post "game/:id/move"      => "game#move"
  post "game/:id/no_move"   => "game#no_move"
  post "game/:id/place"     => "game#place"
  get  "game/:id/players"   => "game#players"
  get  "game/:id/state"     => "game#state"
  post "game/:id/use_cards" => "game#use_cards"
end
