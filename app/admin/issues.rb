ActiveAdmin.register Issue do
  actions :index, :destroy

  config.batch_actions = true
  config.per_page      = 20
  config.sort_order    = 'created_at DESC'

  filter :user_nick, :as => :string, :label => 'User'
  filter :issuable_game_type_title_or_issuable_news_type_title, :as => :string, :label => 'Thread'
  filter :issuable_type, :as => :select, :collection => proc { Issue.distinct :issuable_type }
  filter :created_at

  scope :all, :default => true

  index :download_links => false do
    selectable_column

    column(:user)    { |c| link_to c.user, [:admin, c.user] }
    column(:thread)  { |c| link_to c.issuable, [:admin, c.issuable] }
    column(:issuable_type)
    column(:created_at)

    default_actions
  end

  batch_action :destroy, :confirm => 'Are you sure you want to delete all of these?' do |selection|
    Issue.find(selection).each &:destroy

    flash[:notice] = 'Issues were successfully destroyed.'
    redirect_to admin_issues_path
  end
end
