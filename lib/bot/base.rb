module Bot
  class Base < Weskit::MP::Worker
    def find_user nick, wml
      wml.user.detect { |u| u[:name] == nick }
    end

    def random_name
      f = %w(Reckless Silly Unlucky)
      s = %w(AI Bat Dwarf)

      f.shuffle.first + s.shuffle.first + "#{rand(900) + 100}"
    end

    def user_exists? nick
      User.find_active(nick) ? true : false
    rescue
      false
    end
  end
end
