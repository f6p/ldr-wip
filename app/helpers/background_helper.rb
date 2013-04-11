module BackgroundHelper
  def background_image
    season = approximate_season

    color = season_color season
    image = "backgrounds/#{season}.jpg"

    content_tag :style, <<-STYLE
      body {background: #{color} url(#{asset_path image}) no-repeat fixed bottom center}
    STYLE
  end

  private

  def approximate_season
    case Time.now.month
      when 1..4 then :winter
      when 5..8 then :summer
      else :fall
    end
  end

  def season_color season
    case season
      when :winter then '#808c9a'
      when :summer then '#a2e9ff'
      else '#6f7983'
    end
  end
end
