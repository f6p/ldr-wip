module Replay
  class Chat
    extend  Forwardable
    include Enumerable

    def_delegators :entries, :each, :empty?, :size, :to_a, :to_ary

    attr_reader :entries

    def initialize game
      @game  = game
      @nodes = game.nodes.replay.command.speak
      parse
    end

    def parse
      @entries = @nodes.collect do |entry|
        speaker  = clean find_speaker entry
        message  = clean entry[:message]
        observer = entry[:team_name] == 'observer'

        {:speaker => speaker, :message => message, :observer => observer}
      end
    end

    def to_s
      entries.reduce(Array.new) { |a, e| a << e[:speaker] + ': ' + e[:message] }.join $/
    end

    private

    def clean object
      object.strip.gsub /\s+/, ' '
    rescue
      nil
    end

    def find_speaker entry
      return entry[:id] if entry[:id]

      side = @game.sides.find { |s| s.number == entry[:side] }
      side.player.to_s rescue false
    end
  end
end
