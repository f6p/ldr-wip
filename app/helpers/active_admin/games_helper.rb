module ActiveAdmin::GamesHelper
  def players game
    game.players.collect { |p| admin_nick(p) }.join(', ').html_safe
  end

  def admin_nick player
    nick player, admin_user_path(player)
  end

  def sides game
    game.sides.collect(&:to_s).join('<br />').html_safe
  end
end
