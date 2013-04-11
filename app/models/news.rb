class News < BaseModel
  self.per_page = 5

  attr_accessible :title, :body, :as => :admin

  has_many :comments, :as => :commentable, :dependent => :destroy
  has_one  :issue, :as => :issuable, :dependent => :destroy

  before_validation :strip_attributes

  validates_presence_of :title, :body

  default_scope order('created_at DESC')

  def observers
    comments.collect(&:author).uniq
  end

  def to_param
    "#{id} #{title}".parameterize
  end

  def to_s
    title
  end

  private

  def strip_attributes
    strip :title, :body
  end
end
