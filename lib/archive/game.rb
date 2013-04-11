module Archive
  class Game
    attr_reader :date, :file, :players

    def initialize date, file, players
      @date = date
      @file = file
      @players = players.collect &:downcase
    end

    def link
      URL + date.strftime(DIRECTORY_FORMAT) + '/' + file
    end

    def name
      File.basename(file, '.gz').titleize
    end

    def to_s
      players.unshift(link).join ', '
    end
  end
end
