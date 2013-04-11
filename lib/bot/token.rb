require 'timeout'

module Bot
  class Token < Base
    def deliver
      return [false, 'Already registered'] if user_exists? @nick

      Timeout.timeout(10) do
        connect_and do
          user = find_user @nick, read
          read # server welcome message

          return [false, 'Not in lobby'] unless user
          return [false, 'Not registered on forums'] unless user[:registered]

          send_token
          sleep 3
        end
      end
    rescue StandardError, TimeoutError
      [false, 'Could not connect to lobby']
    else
      [true, 'Registration token delivered']
    end

    def initialize nick, code
      super random_name

      @code  = "#{code}"
      @nick  = "#{nick}".strip
    end

    private

    def send_token
      message :whisper, :message => "Registration token: #{@code}", :receiver => @nick
    end
  end
end
