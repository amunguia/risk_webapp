class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.text     :army_map_str
      t.text     :assignment_map_str
      t.string   :card_list
      t.text     :cards_str
      t.integer  :max_place
      t.integer  :minimum_move
      t.string   :move_from_str
      t.string   :move_to_str
      t.string   :players_str
      t.string   :players_map_str
      t.integer  :players_to_setup
      t.integer  :state_id
      t.boolean  :won

      t.timestamps null: false
    end
  end
end
