class AddInitialVolatilityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :initial_volatility, :float, :default => 0.6, :null => false
  end
end
