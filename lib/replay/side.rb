module Replay
  class Side
    def initialize game, nodes
      @game  = game
      @nodes = nodes
    end

    def color
      @color ||= find_color
    end

    def faction
      @faction ||= find_faction
    end

    def hash_without_player
      to_hash.tap { |h| h.delete :player }
    end

    def leader
      @leader ||= find_leader
    end

    def number
      @number ||= @nodes[:side].to_i
    end

    def player
      @player ||= @nodes[:name] || @nodes[:save_id].chop
    end

    def team
      @team ||= @nodes[:team_name]
    end

    def to_hash
      {
        :color   => color,
        :faction => faction,
        :leader  => leader,
        :number  => number,
        :player  => player,
        :team    => team
      }
    end

    def valid?
      color && faction && leader && player && team && (number > 0)
    end

    alias_method :to_h, :to_hash

    def to_s
      "#{number} / #{team} / #{player} / #{faction} / #{leader}"
    end

    private

    def find_color
      Color.find @nodes[:color]
    end

    def find_faction
      guess_faction recruit_list
    end

    def find_leader
      return @nodes[:type] if @nodes[:type]
      @nodes.unit.detect { |u| u[:canrecruit] }[:type]
    end

    def guess_faction string
      case string
        when /Cavalryman/ then 'Loyalists'
        when /Drake/      then 'Drakes'
        when /Dwarvish/   then 'Knalgan Alliance'
        when /Elvish/     then 'Rebels'
        when /Orcish/     then 'Northerners'
        when /Skeleton/   then 'Undead'
      end
    end

    def recruit_list
      @nodes[:previous_recruits] || @nodes[:recruit]
    end
  end
end
