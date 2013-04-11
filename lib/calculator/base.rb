require 'glicko2'

module Calculator
  class Base
    attr_reader :game, :scores

    def initialize game, result, by
      @game   = game
      @result = result.to_f
      @by     = by
      @scores = {}

      set_scores
    end

    def sides
      scores.reduce(Array.new) do |array, (player, score)|
        array << Hash[:player => player, :score => score]
      end
    end

    def to_s
      scores.collect { |p, s| "#{p} #{s}" }.join ' / '
    end

    def update_ratings
      period = Glicko2::RatingPeriod.from_objs game.sides
      period.game *game_results

      Game.transaction do
        period.generate_next.players.each do |p|
          p.update_obj and p.obj.save!
          p.obj.player.update_rating p.obj
        end
      end
    end

    private

    def game_results
      initial = [[], []]

      game.sides.reduce(initial) do |results, side|
        results[0] << side
        results[1] << score_to_rank(side.score)

        results
      end
    end

    def oposite_result
      Game::RESULTS[:win] - @result
    end

    def score_to_rank score
      !score.zero? ? 1 : 2
    end
  end
end
