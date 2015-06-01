class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :max_place
      t.integer :minimum_move
      t.integer :players_to_setup
      t.boolean :won
      t.text :cards_string
      t.string :card_list
      t.string :players_string
      t.text :army_map_string
      t.text :assignment_map_string
      t.integer :state_id
      t.string :move_from_string
      t.string :move_to_string

      t.timestamps null: false
    end
  end
end
