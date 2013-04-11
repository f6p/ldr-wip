module RatingHelper
  def glicko2 object
    Glicko2::Util.to_glicko2 object.rating, object.rating_deviation
  end

  def interval object
    times = 2
    lower = (object.rating - object.rating_deviation * times).to_i
    upper = (object.rating + object.rating_deviation * times).to_i
    "(#{lower} - #{upper})"
  end

  def rating_with_interval object
    return object.visible_rating unless object.competitive?
    "#{object.visible_rating} #{interval object}"
  end
end
