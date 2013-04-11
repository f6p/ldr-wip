require 'cgi'

module Ladder
  class Game
    attr_reader :date, :loser, :winner

    def eql? object
      object.date   == @date  && \
      object.loser  == @loser && \
      object.winner == @winner
    rescue
      false
    end

    def initialize date, winner, loser, replay
      @date    = DateTime.strptime date, DateFormatter.date_format
      @replay  = replay
      @revoked = has_revoked_marker loser, winner

      @loser, @winner = cleanup loser, winner
    end

    def replay?
      @replay
    end

    def replay
      date = @date.strftime DateFormatter.date_format
      "#{Game.replay_url}?reported_on=#{CGI.escape date}"
    end

    def revoked?
      @revoked
    end

    def to_hash
      {
        :date    => @date,
        :loser   => @loser,
        :winner  => @winner,
        :replay  => @replay,
        :revoked => @revoked
      }
    end

    def to_s
      "#{DateFormatter.new @date} #{Color.green @winner} #{Color.red @loser} #{@replay}"
    end

    def to_yaml
      to_hash.to_yaml
    end

    def self.replay_url
      "#{URL}download_replay.php"
    end

    private

    def cleanup *players
      players.collect { |p| p.gsub '*', '' }
    end

    def has_revoked_marker *players
      "#{players}".include? '*'
    end
  end
end
