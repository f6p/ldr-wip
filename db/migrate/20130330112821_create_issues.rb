class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.references :user,          :null => false
      t.integer    :issuable_id,   :null => false
      t.string     :issuable_type, :null => false

      t.timestamps
    end
  end
end
