module LinkHelper
  def link_to_admin_panel address
    link_to 'Admin Actions', address, :class => 'admin'
  end

  def link_to_destroy_comment comment
    p = polymorphic_path [comment.commentable, comment]
    link_to 'Delete', p, :confirm => 'Are you sure you want to delete this?', :method => :delete
  end

  def link_to_edit_comment comment
    p = edit_polymorphic_path [comment.commentable, comment]
    link_to 'Edit', p
  end

  def link_to_github
    alt = 'Fork me on Github'
    img = 'https://s3.amazonaws.com/github/ribbons/forkme_right_gray_6d6d6d.png'
    link_to image_tag(img, :alt => alt), 'https://github.com/f6p/ldr-wip', :class => 'github'
  end

  def link_to_gravatar
    link_to 'Gravatar', 'http://gravatar.com/'
  end

  def link_to_object object, options = {}
    link_to "#{object}", object, options
  end

  def link_to_replay game
    label =  "Replay"
    label += " (#{game.downloads})" unless game.downloads.zero?
    link_to label, download_game_path(game)
  end

  def link_to_textile
    link_to 'Textile', 'http://redcloth.org/textile/'
  end

  def link_to_user_games user
    address = games_path :search => {:sides_player_nick_eq => user.nick}
    link_to "Find Games (#{user.games.size})", address
  end
end
