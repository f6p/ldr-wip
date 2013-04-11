module Replay
  class Color
    def self.all
      %w(red blue green purple black brown orange white teal)
    end

    def self.find index
      all[index.to_i - 1]
    end
  end
end
