class CreateSides < ActiveRecord::Migration
  def change
    create_table :sides do |t|
      t.references :game,                    :null => false
      t.references :player,                  :null => false
      t.float      :score,                   :null => false
      t.float      :rating,                  :null => false
      t.float      :rating_before,           :null => false
      t.float      :rating_deviation,        :null => false
      t.float      :rating_deviation_before, :null => false
      t.float      :volatility,              :null => false
      t.float      :volatility_before,       :null => false
      t.string     :kind
      t.integer    :number
      t.string     :color
      t.string     :team
      t.string     :faction
      t.string     :leader

      t.timestamps
    end

    add_index :sides, :game_id
    add_index :sides, :player_id
  end
end
