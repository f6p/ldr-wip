module Calculator
  class Simple < Base
    def initialize game, result, by, vs
      @vs = vs
      super game, result, by
    end

    private

    def set_scores
      @scores[@by] = @result
      @scores[@vs] = oposite_result
    end
  end
end
