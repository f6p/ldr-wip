ActiveAdmin.register Game do
  actions :index, :show, :destroy, :download

  config.batch_actions = true
  config.per_page      = 20
  config.sort_order    = 'created_at DESC'

  filter :sides_player_nick, :as => :string, :label => 'Player'
  filter :kind, :as => :select, :collection => proc { Game.distinct :kind }
  filter :created_at
  filter :updated_at

  scope :all, :default => true
  scope :parsed
  scope :revoked
  scope :unparsed
  scope :unrevoked

  index :download_links => false do
    selectable_column

    column(:players) { |g| players g }
    column(:kind)
    column(:parsed)
    column(:revoked)
    column(:created_at)
    column(:updated_at)

    default_actions
  end

  show :title => :title do |game|
    attributes_table do
      row(:players) { players game }
      if game.parsed?
        row(:summary) { game_replay_title game }
        row(:era)
        row(:replay) { link_to_replay game }
        row(:version)
        row(:sides) { sides game }
      end
      row(:kind)
      row(:parsed)
      row(:revoked)
      if game.revoked?
        row(:revoked_by) { admin_nick game.revoked_by rescue nil }
      end
      if game.issue
        row(:issue_by) { admin_nick game.issue.user }
      end
      row(:created_at)
      row(:updated_at)
    end
  end

  member_action :reset, :method => :post do
    game = Game.find params[:id]
    game.reset

    flash[:notice] = 'Game was successfully reset.'
    redirect_to :action => :show
  end

  member_action :make_casual, :method => :post do
    game = Game.find params[:id]
    game.change_kind_to 'Casual'

    flash[:notice] = 'Game kind was set to casual.'
    redirect_to :action => :show
  end

  member_action :make_competitive, :method => :post do
    game = Game.find params[:id]
    game.change_kind_to 'Competitive'

    flash[:notice] = 'Game kind was set to competitive.'
    redirect_to :action => :show
  end

  member_action :revoke, :method => :post do
    game = Game.find params[:id]
    game.revoke current_user

    flash[:notice] = 'Game was successfully revoked.'
    redirect_to :action => :show
  end

  member_action :unrevoke, :method => :post do
    game = Game.find params[:id]
    game.unrevoke

    flash[:notice] = 'Game was successfully unrevoked.'
    redirect_to :action => :show
  end

  action_item :except => :index do
    if game.parsed?
      link_to 'Reset Game', reset_admin_game_path(game), :confirm => 'Are you sure you want to reset this?', :method => :post
    end
  end

  action_item :except => :index do
    unless game.revoked?
      link_to 'Revoke Game', revoke_admin_game_path(game), :confirm => 'Are you sure you want to revoke this?', :method => :post
    else
      link_to 'Unrevoke Game', unrevoke_admin_game_path(game), :confirm => 'Are you sure you want to unrevoke this?', :method => :post
    end
  end

  action_item :except => :index do
    unless game.casual?
      link_to 'Make Casual', make_casual_admin_game_path(game), :confirm => 'Are you sure you want to make this casual?', :method => :post
    else
      link_to 'Make Competitive', make_competitive_admin_game_path(game), :confirm => 'Are you sure you want to make this competitive?', :method => :post
    end
  end

  action_item :except => :index do
    link_to 'Show Game', game
  end

  batch_action :destroy, :confirm => 'Are you sure you want to delete all of these?' do |selection|
    Game.find(selection).each &:destroy

    flash[:notice] = 'Games were successfully destroyed.'
    redirect_to admin_games_path
  end

  batch_action :reset do |selection|
    Game.find(selection).each &:reset

    flash[:notice] = 'Games were successfully reset.'
    redirect_to admin_games_path
  end

  batch_action :revoke do |selection|
    Game.find(selection).each { |g| g.revoke current_user }

    flash[:notice] = 'Games were successfully revoked.'
    redirect_to admin_games_path
  end

  batch_action :unrevoke do |selection|
    Game.find(selection).each &:unrevoke

    flash[:notice] = 'Games were successfully unrevoked.'
    redirect_to admin_games_path
  end
end
