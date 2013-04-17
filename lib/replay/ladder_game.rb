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

    private

    def raise_parser_error replay, error
      Rails.logger.warn "#{Time.now} - Parse Error - #{error} (#{replay})"
      super
    end
  end
end
