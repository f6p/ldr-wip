module Weskit::MP
  class Connection
    def defaults
      {
        :debug   => false,
        :host    => 'server.wesnoth.org',
        :port    => 15000,
        :version => ::Bot::VER
      }
    end
  end
end
