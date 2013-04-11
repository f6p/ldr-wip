require 'open-uri'

module Ladder
  class History
    def initialize from = START, to = DateTime.now
      @from = from.to_datetime
      @to   = to.to_datetime
    end

    def retrieve
      @current = @games = unrevoked_games @to

      while continue?
        @current = unrevoked_games @current.oldest_date
        @games  += @current
      end

      cleanup
    end

    private

    def cleanup
      @games.reject! { |g| g.date < @from }
      @games.uniq.reverse
    end

    def continue?
      return false if @current.empty?

      @current.oldest_date.valid?   && \
      @current.oldest_date >= @from && \
      @current.oldest_date <= @to
    end

    def revoked_games date
      games(date).reject { |g| not g.revoked? }
    end

    def unrevoked_games date
      games(date).reject { |g| g.revoked? }
    end

    def games date
      addr = DateFormatter.new(date).to_url
      data = Nokogiri.HTML(open addr).games
      data.collect { |g| Game.new *g }
    end
  end
end
