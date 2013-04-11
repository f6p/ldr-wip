class Page < BaseModel
  attr_accessible :title, :body, :menu, :as => :admin

  before_validation :strip_attributes

  validates_presence_of   :title, :body
  validates_uniqueness_of :title

  scope :menu, where(:menu => true)
  default_scope order(:title)

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
