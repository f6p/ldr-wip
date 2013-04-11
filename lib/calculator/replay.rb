module Calculator
  class Replay < Base
    def initialize game, result, by, replay
      @replay = replay
      super game,result, by
    end

    private

    def set_scores
      by_team = @replay.sides.detect { |s| s.player == @by }.team rescue nil
      return false unless by_team

      @replay.sides.each do |side|
        @scores[side.player] = (side.team == by_team) ? @result : oposite_result
      end
    end
  end
end
