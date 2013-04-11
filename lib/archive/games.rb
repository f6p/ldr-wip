require 'open-uri'

module Archive
  class Games
    attr_reader :date, :list

    def initialize date
      @date = date
    end

    def read
      @list = Nokogiri.HTML(open url).list
      self
    end

    def url
      URL + @date.strftime(DIRECTORY_FORMAT)
    end
  end
end
