require 'timeout'

module Replay
  class Game
    attr_accessor :nodes, :replay

    def chat
      @chat ||= Replay::Chat.new self
    end

    def era
      @era ||= titleize @nodes.multiplayer[:mp_era] || @nodes.replay_start.multiplayer[:mp_era]
    end

    def initialize replay
      replay.strip!

      @nodes  = Timeout.timeout(30) { Weskit::WML::Parser.uri replay, :simple }
      @replay = replay
    rescue SocketError, TimeoutError
      raise 'Replay could not be downloaded.'
    rescue
      raise 'Replay could not be parsed.'
    end

    def hash_without_sides
      to_hash.tap { |h| h.delete :sides }
    end

    def map
      @map ||= titleize @nodes.replay_start[:name].gsub /^\dp(\s*-\s*)?/, ''
    end

    def players
      @players ||= sides.collect &:player
    end

    def rby?
      @rby ||= !!(@nodes.replay_start[:id] =~ /^RBY/)
    end

    def rmp?
      @rmp ||= !!(@nodes.replay_start[:id] =~ /^RMP/)
    end

    def sides
      @sides ||= playable_sides.collect { |s| Replay::Side.new self, s }
    end

    def teams
      @teams ||= sides.collect &:team
    end

    def title
      @title ||= titleize @nodes[:mp_game_title] || @nodes.multiplayer[:scenario]
    end

    def turns
      @turns ||= @nodes[:label].split(' Turn ').last.to_i
    end

    def valid?
      all_attributes? and proper_titles? and valid_sides?
    end

    def version
      @version ||= @nodes[:version].split('.')[0, 2].join('.')
    end

    def to_hash
      {
        :chat    => chat.to_a,
        :era     => era,
        :map     => map,
        :replay  => replay,
        :sides   => sides,
        :turns   => turns,
        :title   => title,
        :version => version
      }
    end

    alias_method :to_h, :to_hash

    def proper_titles?
      not [era, map, title].any? &:empty?
    end

    def to_s
      "#{players.size}p #{map} Turn #{turns}"
    end

    private

    def all_attributes?
      era && map && title && version && (turns > 0)
    end

    def playable_sides
      @playable_sides ||= @nodes.replay_start.side.reject { |s| s[:allow_player] == false }
    end

    def titleize object
      options = {
        :invalid => :replace,
        :undef   => :replace,
        :replace => ''
      }

      text = "#{object}".encode Encoding.find('ASCII'), Encoding.find('UTF-8'), options
      text = text.strip.titleize.gsub(/\s+/, ' ').gsub('Rby', 'RBY')

      text.gsub /(http:\/\/[^\s]*)/i, "#{$1}".downcase
    end

    def valid_sides?
      sides.all? &:valid?
    end
  end
end
