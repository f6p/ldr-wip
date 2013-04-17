require 'concerns/models/kind'
require 'ladder'

class User < BaseModel
  include Concerns::Models::Kind

  # :confirmable, :lockable, :omniauthable, :registerable,
  # :timeoutable, :token_authenticatable, :validatable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable

  alias_attribute :name, :nick

  attr_accessible :country, :rating_import, :kind, :nick, :password, :password_confirmation, :remember_me, :time_zone, :token
  attr_accessible :admin, :banned, :as => :admin
  attr_accessible :email, :as => [:admin, :default]
  attr_readonly   :nick
  attr_accessor   :import_status, :rating_import, :token, :token_confirmation, :token_nick

  serialize :notifications

  has_many :sides, :foreign_key => :player_id
  has_many :games, :through => :sides

  before_validation :set_rating, :if => :unregistered_user?
  before_validation :strip_attributes

  validate  :validate_import, :validate_token
  validates :nick, :uniqueness => true, :presence => true
  validates :password, :confirmation => true, :length => {:minimum => 6}, :if => :validate_password?
  validates_inclusion_of :kind, :in => %w(Competitive Casual)

  with_options :allow_blank => true, :allow_nil => true do |e|
    e.validates_format_of    :email,     :with => /^[^@\s]+@[^@\s]+$/
    e.validates_inclusion_of :country,   :in => Country.codes
    e.validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.zones_map(&:name)
  end

  scope :admins, where(:admin  => true)
  scope :banned, where(:banned => true)
  default_scope order('users.rating DESC, users.nick')

  def active_for_authentication?
    super and not banned?
  end

  def manageable_by? user
    self == user
  end

  def unregistered_user?
    new_record? || unregistered? || was_unregistered?
  end

  def validate_password?
    unregistered_user? || !password.blank?
  end

  def apply_rating_from_old_ladder
    player = Ladder::Player.new(nick).read
    self.rating = player.rating
  end

  def as_json options = {}
    options.reverse_merge! :methods => [:visible_rating, :country_name]
    options.reverse_merge! :only    => [:id, :nick, :kind, :time_zone, :visible_rating, :admin, :banned]

    super options
  end

  def country_name
    Country.find country if country
  end

  def do_import?
    self.rating_import == '1'
  end

  def notify hash
    return false if unregistered?

    hashes =  notifications || Array.new
    hashes.unshift hash.merge(:date => DateTime.now)

    self.notifications = hashes[0, 25]
    save
  end

  def local_time time
    time.to_time.in_time_zone time_zone
  end

  def ratings
    [initial_rating] + sides.competitive.unrevoked.collect(&:rating)
  end

  def soft_save
    registered? ? save! : save!(:validate => false)
    self
  end

  def update_rating side
    self.rating           = side.rating
    self.rating_deviation = side.rating_deviation
    self.volatility       = side.volatility

    soft_save
  end

  def to_param
    "#{id} #{nick}".parameterize
  end

  def to_s
    nick
  end

  def visible_rating
    return 'Hidden' unless competitive?
    rating.to_i
  end

  def self.find_registered nick
    registered.with_nick nick
  end

  def self.find_unregistered nick
    unregistered.with_nick nick
  end

  def self.find_or_create nick
    with_nick nick
  rescue
    user = new :nick => nick, :kind => 'Unregistered'
    user.soft_save
  end

  def self.find_or_new nick
    find_unregistered nick rescue new :nick => nick
  end

  def self.with_nick nick
    where('LOWER(nick) = ?', nick.downcase).first!
  end

  def self.register nick, token, params
    user = find_or_new params[:nick]
    user.attributes = params.merge registered_defaults

    user.token_confirmation = token
    user.token_nick = nick

    user
  end

  private

  def reset_deviation_and_volatility
    self.initial_rating_deviation = self.rating_deviation = 350
    self.volatility = 0.06
  end

  def set_rating
    reset_deviation_and_volatility
    raise unless do_import?

    apply_rating_from_old_ladder
    self.initial_rating = rating
    self.import_status = true
  rescue
    self.initial_rating = self.rating = 1500
    self.import_status = false ; true
  end

  def import_failure?
    do_import? != import_status
  end

  def strip_attributes
    strip :email, :nick, :password, :password_confirmation
  end

  def token_mismatch?
    token.empty? || (token != token_confirmation) || (nick != token_nick)
  end

  def validate_import
    if unregistered_user? && do_import? && import_failure?
      errors.add :rating_import, 'failed, maybe you made a typo in nick, otherwise try again later'
    end
  end

  def validate_token
    if LdrWip::Application.config.lobby_auth && unregistered_user? && token_mismatch?
      errors.add :token, 'is invalid'
    end
  end

  def self.registered_defaults
    {:kind => 'Competitive'}
  end
end
