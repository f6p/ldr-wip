require 'open-uri'

module Ladder
  class Player
    attr_reader :name, :rating

    def initialize name
      @name = name.strip
    end

    def read
      addr = "#{Player.profile_url}?name=#{name}"
      @rating = Nokogiri.HTML(open addr).rating
      self
    end

    def self.profile_url
      "#{URL}profile.php"
    end
  end
end
