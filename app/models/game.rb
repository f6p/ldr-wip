require 'calculator'
require 'concerns/models/kind'

class Game < BaseModel
  include Concerns::Models::Kind

  self.per_page = 10

  RESULTS = {
    :win  => 1.0,
    :draw => 0.5,
    :loss => 0.0
  }

  attr_accessor :against, :parsed_replay

  serialize :chat

  with_options :class_name => 'User' do |u|
    u.belongs_to :reported_by
    u.belongs_to :revoked_by
  end

  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :players, :through => :sides, :class_name => 'User'
  has_many :sides, :dependent => :destroy
  has_one  :issue, :as => :issuable, :dependent => :destroy

  validate :validate_loser, :validate_ownership, :validate_replay, :validate_scores, :validate_sides_size

  after_validation :humanize_side_errors

  scope :parsed,    where(:parsed  => true)
  scope :revoked,   where(:revoked => true)
  scope :unparsed,  where(:parsed  => false)
  scope :unrevoked, where(:revoked => false)
  scope :ranked,    competitive.unrevoked
  default_scope includes(:sides).order('games.id DESC')

  def draw?
    sides.any? { |s| s.draw? }
  end

  def manageable_by? user
    new_record? || user.admin? || (update_possible? and players.include? user)
  rescue
    false
  end

  def update_possible?
    !parsed? || !revoked?
  end

  def add_save_error
    errors.add :base, 'Game could not be reported' if valid?
    self
  end

  def apply replay
    hash = {:parsed => true}.merge replay.hash_without_sides
    assign_attributes hash, :without_protection => true

    Game.transaction do
      sides.each do |side|
        side.apply replay.sides.detect { |s| side.player == s.player }
      end
      save!
    end
  end

  def as_json options = {}
    side_options = {
      :methods => [:player_nick, :visible_rating],
      :only    => [:player_id, :score, :kind, :number, :color, :team, :faction, :leader]
    }

    options.reverse_merge! :except  => [:reported_by_id, :chat, :revoked_by_id]
    options.reverse_merge! :include => [:sides => side_options]

    super options
  end

  def change_kind_to new_kind
    Game.transaction do
      sides.each { |s| s.kind = new_kind ; s.save! }
      self.kind = new_kind ; save!
    end
  end

  def destroy
    revoke nil
    super
  end

  def filename
    file_id = "#{id}".rjust 7, '0'
    file_players = players.join ' '

    "#{file_id} #{map} #{file_players}".parameterize('-') + '.gz'
  end

  def increase_downloads
    increment! :downloads
  end

  def make_casual
    Game.transaction do
      sides.each &:make_casual
      update_attribute :kind, 'Casual'
    end
  end

  def make_competitive
    Game.transaction do
      sides.each &:make_competitive
      update_attribute! :kind, 'Competitive'
    end
  end

  def notify_about_report player, score
    list = observers - [player]
    list.each { |o| o.notify game_report_notification player, score }
  end

  def observers
    (players + comments.collect(&:author)).uniq
  end

  def privileged_sides
    return sides.reject &:lose? unless sides.any? &:draw?
    return [sides.first] unless parsed?

    sides.reject { |s| reported_by_side.team != s.team }
  end

  def reset
    self.title = 'Ladder Game'
    self.downloads = 0

    set nil, :era, :map, :turns, :chat, :replay, :revoked_by, :version
    set false, :parsed, :revoked

    Game.transaction do
      sides.each &:reset
      save!
    end
  end

  def revoke user
    return false if revoked?

    self.revoked_by = user
    self.revoked = true

    Game.transaction do
      sides.each &:revoke
      save!
    end

    if revoked_by
      list = observers - [user]
      list.each { |o| o.notify revoke_notification }
    end

    true
  end

  def teams
    sides.group_by { |s| s.team } if parsed?
  end

  def to_param
    "#{id} #{title}".parameterize
  end

  def to_s
    title
  end

  def unprivileged_sides
    return sides.reject &:won? unless sides.any? &:draw?
    return [sides.last] unless parsed?

    sides.reject { |s| reported_by_side.team == s.team }
  end

  def unrevoke
    set false, :revoked, :revoked_by

    Game.transaction do
      sides.each &:unrevoke
      save!
    end
  end

  def update_game_type
    self.kind = (sides.all? &:competitive?) ? 'Competitive' : 'Casual'
    save!
  end

  class << self
    def eras
      distinct :era
    end

    def maps
      distinct :map
    end

    def report result, by, vs
      game = Game.new
      game.against = vs
      game.reported_by = by

      calculator = Calculator::Simple.new game, result, by, vs
      game.sides.build calculator.sides

      Game.transaction do
        game.save!
        game.update_game_type
        calculator.update_ratings
      end

      game.notify_about_report by, result
      game
    rescue ActiveRecord::RecordInvalid, StandardError
      game.add_save_error
    end

    def report_replay result, by, replay
      game = Game.new
      game.parsed_replay = replay
      game.reported_by = by

      calculator = Calculator::Replay.new game, result, by, replay
      game.sides.build calculator.sides

      Game.transaction do
        game.save!
        game.update_game_type
        calculator.update_ratings
        game.apply replay
      end

      game.notify_about_report by, result
      game
    rescue ActiveRecord::RecordInvalid, StandardError
      game.add_save_error
    end

    alias_method :meta_search, :search

    def search params
      return meta_search nil unless params

      if !params[:sides_rating_gte].blank? || !params[:sides_rating_lte].blank?
        params.merge! :sides_kind_eq => 'Competitive'
      end

      group(column_list).meta_search params
    end
  end

  private

  def humanize_side_errors
    if errors[:sides].any?
      errors.add :base, 'Invalid side'
      errors.delete :sides
    end
  end

  def game_report_notification user, score
    type = RESULTS.invert[score.to_f]
    {:event => :report, :by_id => user.id, :type => type, :id => id}
  end

  def reported_by_side
    sides.find { |s| s.player == reported_by }
  end

  def revoke_notification
    {:event => :revoke, :by_id => revoked_by.id, :id => id}
  end

  def validate_loser
    if against == reported_by
      errors.add :base, 'Are you kidding me?'
    end
  end

  def validate_ownership
    if parsed_replay && !parsed_replay.players.include?(reported_by)
      errors.add :base, 'Game has to be played by you'
    end
  end

  def validate_replay
    if parsed_replay && !parsed_replay.valid?
      errors.add :replay, 'is invalid'
    end
  end

  def validate_scores
    if teams
      winner_teams_size = sides.collect(&:won?).count true
      errors.add :base, 'Game should have only one winner' if winner_teams_size > 1
    end
  end

  def validate_sides_size
    unless sides.empty?
      errors.add :base, 'Game has invalid number of sides' if sides.size == 1
    end
  end
end
