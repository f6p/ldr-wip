module Replay
  class LadderGame < Game
    def initialize nodes
      super and sides
    end

    def played_by? users
      (players - users.to_a).empty? rescue false
    end

    def sides
      @sides ||= playable_sides.collect { |s| Replay::LadderSide.new self, s }
    end
  end
end
