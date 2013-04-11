require 'archive/extensions'
require 'archive/game'
require 'archive/games'

module Archive
  VER = LdrWip::Application.config.wesnoth_version
  URL = "http://replays.wesnoth.org/#{VER}/"
  DIRECTORY_FORMAT = '%Y%m%d'
end
