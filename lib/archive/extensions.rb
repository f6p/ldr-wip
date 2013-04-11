module Nokogiri::XML
  class Node
    def list
      archive_path = '/html/body/table/tr[position() > 3]'

      items = search(archive_path).collect { |i| i.game }
      items.pop
      items
    end

    def game
      begin
        date = DateTime.parse at('td[3]').content
        file = at('td[2]/a')[:href]
        players = at('td[5]').content.split(': ').last.split(', ')
      rescue
        return nil
      end

      ::Archive::Game.new date, file, players
    end
  end
end
