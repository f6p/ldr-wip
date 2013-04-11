class Issue < BaseModel
  attr_readonly   :user_id

  belongs_to :user
  belongs_to :issuable, :polymorphic => true

  validates_uniqueness_of :issuable_id, :scope => :issuable_type

  default_scope order('created_at DESC')

  def self.exists? type, id
    !!(find_by_issuable_type_and_issuable_id type, id)
  end
end
