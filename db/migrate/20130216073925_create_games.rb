class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :reported_by, :null => false
      t.string     :kind
      t.string     :version
      t.string     :title,       :null => false, :default => 'Ladder Game'
      t.string     :era
      t.string     :map
      t.integer    :turns
      t.text       :chat
      t.string     :replay
      t.integer    :downloads,   :null => false, :default => 0
      t.boolean    :parsed,      :null => false, :default => false
      t.boolean    :revoked,     :null => false, :default => false
      t.references :revoked_by

      t.timestamps
    end
  end
end
