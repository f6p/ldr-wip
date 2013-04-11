module GamesHelper
  def archive_link text, date = nil, options = {}
    base = "http://replays.wesnoth.org/#{LdrWip::Application.config.wesnoth_version}/"
    return link_to text, base unless date

    date = date.strftime '%Y%m%d'
    link_to text, "#{base}#{date}/", options
  end

  def rating_delta side
    '(%+d)' % side.delta(:rating)
  end

  def game_chat_row entry, &block
    css = game_chat_entry_class entry
    content_tag(:tr, :class => css) { block.call }
  end

  def game_feed_title game
    "#{game.kind}: #{collect_player_names game.privileged_sides} VS #{collect_player_names game.unprivileged_sides}"
  end

  def game_replay_title game
    "#{game.map} Turn #{game.turns}"
  end

  def game_title_link game
    prefix = game.revoked ? 'Revoked:' : ''
    link_to "#{prefix} #{game}", game
  end

  def side_for_select
    selected = params[:search][:sides_number_eq] rescue nil
    options_for_select 1..9, selected
  end

  private

  def collect_player_names sides
    sides.collect { |s| s.player.to_s }.join ' & '
  end

  def game_chat_entry_class entry
    return 'observer' if entry[:observer]
    return 'server'   if entry[:speaker] == 'server'

    @game.sides.find { |s| s.player.nick.downcase == entry[:speaker].downcase }.try :color
  end
end
