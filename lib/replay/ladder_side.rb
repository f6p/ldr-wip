module Replay
  class LadderSide < Side
    def initialize game, nodes
      super and player
    end

    def player
      @player ||= User.find_or_create(super).tap do |player|
        if player.unregistered_user?
          begin
            player.apply_rating_form_old_ladder
            player.soft_save
          rescue
            nil
          end
        end
      end
    end
  end
end
