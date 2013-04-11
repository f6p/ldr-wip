class Comment < BaseModel
  attr_accessible :content
  attr_readonly   :author_id

  belongs_to :author, :class_name => 'User'
  belongs_to :commentable, :polymorphic => true

  after_create :notify_about_comment
  before_validation :strip_attributes

  validates_presence_of :author, :content

  default_scope order(:created_at)

  def editable_by? user
    new_record? || user.admin? || (author == user) && (created_at > 15.minutes.ago)
  rescue
    false
  end

  private

  def notify_about_comment
    obs = commentable.observers - [author]
    obs.each { |o| o.notify :event => :comment, :by_id => author.id, :type => commentable_type, :id => commentable_id }
  end

  def strip_attributes
    strip :content
  end
end
