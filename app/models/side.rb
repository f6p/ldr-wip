require 'concerns/models/kind'

class Side < BaseModel
  include Concerns::Models::Kind

  attr_accessible :player, :score
  attr_readonly   :player_id, :score

  belongs_to :game
  belongs_to :player, :class_name => 'User'

  validates_presence_of :player, :score

  scope :losers,    where(:score => Game::RESULTS[:loss])
  scope :winners,   where(:score => Game::RESULTS[:win])
  scope :unrevoked, joins(:game).where('games.revoked = ?', false)
  default_scope order('sides.game_id, sides.number, sides.score DESC, sides.rating, sides.id')

  def draw?
    score == Game::RESULTS[:draw]
  end

  def lose?
    score == Game::RESULTS[:loss]
  end

  def won?
    score == Game::RESULTS[:win]
  end

  def apply side
    assign_attributes side.hash_without_player, :without_protection => true
    save!
  end

  def as_json options = {}
    player.as_json.merge :visible_rating => visible_rating
  end

  def delta attribute
    send("#{attribute}") - send("#{attribute}_before")
  end

  def destroy
    revoke
    super
  end

  def place
    return 1 if won?
    2
  end

  def player= p
    self.ratings           = p.rating
    self.rating_deviations = p.rating_deviation
    self.volatilities      = p.volatility
    self.kind              = p.kind

    super
  end

  def player_nick
    player.nick
  end

  def ratings= rating
    set rating, :rating, :rating_before
  end

  def rating_deviations= deviation
    set deviation, :rating_deviation, :rating_deviation_before
  end

  def reset
    set nil, :number, :color, :team, :faction, :leader
    save!
  end

  def revoke
    unless game.revoked?
      player.rating           -= delta(:rating)
      player.rating_deviation -= delta(:rating_deviation)
      player.volatility       -= delta(:volatility)

      player.soft_save
    end
  end

  def to_s
    items =  [player, visible_rating]
    items << [number, faction, leader] if game.parsed?

    items.join ' / '
  end

  def unrevoke
    if game.revoked?
      player.rating           += delta(:rating)
      player.rating_deviation += delta(:rating_deviation)
      player.volatility       += delta(:volatility)

      player.soft_save
    end
  end

  def visible_rating
    return 'Hidden' unless competitive?
    rating.to_i
  end

  def volatilities= volatility
    set volatility, :volatility, :volatility_before
  end

  def self.factions
    distinct :faction
  end

  def self.leaders
    distinct :leader
  end

  def self.ordered_standings params
    subquery = search_standings(params).to_sql
    find_by_sql "SELECT sq.* FROM (#{subquery}) AS sq ORDER BY sq.rating DESC LIMIT 150"
  end

  def self.search_standings params
    select('DISTINCT ON (sides.player_id) sides.player_id, sides.*').joins('RIGHT JOIN games ON sides.kind = games.kind').where('sides.kind = ?', 'Competitive').reorder('sides.player_id, sides.rating DESC').search params
  end
end
