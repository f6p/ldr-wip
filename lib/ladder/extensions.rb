class Array
  def oldest_date
    last.date rescue nil
  end
end

class DateTime
  def valid?
    self > Ladder::START
  end
end

module Nokogiri::XML
  class Node
    def games
      game_path = '#games tbody tr'

      search(game_path).map do |game|
        contents = game.children.collect &:content
        replay   = contents[10][2..3] == 'No'
        contents[0...3] << replay
      end
    end

    def rating
      rating_path = '/html/body/div[3]/table[2]/tbody[1]/tr[1]/td[2]'
      at(rating_path).content.split(' ', 2).first.to_i
    end
  end
end
