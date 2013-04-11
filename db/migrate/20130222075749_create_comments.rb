class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :author,           :null => false
      t.text       :content,          :null => false
      t.integer    :commentable_id,   :null => false
      t.string     :commentable_type, :null => false

      t.timestamps
    end
  end
end
