require 'nokogiri'
require 'term/ansicolor'

require 'ladder/extensions'
require 'ladder/color'
require 'ladder/date_formatter'
require 'ladder/game'
require 'ladder/history'
require 'ladder/player'

module Ladder
  START = DateTime.civil 2007, 9, 20
  URL   = 'http://wesnoth.gamingladder.info/'
end
