ActiveAdmin.register Comment do
  actions :index, :show, :destroy

  config.batch_actions = true
  config.per_page      = 20
  config.sort_order    = 'created_at DESC'

  filter :author_nick, :as => :string, :label => 'Author'
  filter :commentable_game_type_title_or_commentable_news_type_title, :as => :string, :label => 'Thread'
  filter :commentable_type, :as => :select, :collection => proc { Comment.distinct :commentable_type }
  filter :created_at

  scope :all, :default => true

  index :download_links => false do
    selectable_column

    column(:author)  { |c| link_to c.author, [:admin, c.author] }
    column(:thread)  { |c| link_to c.commentable, [:admin, c.commentable] }
    column(:commentable_type)
    column(:created_at)

    default_actions
  end

  show do |comment|
    attributes_table do
      row(:author)  { link_to comment.author, [:admin, comment.author] }
      row(:thread)  { link_to comment.commentable, [:admin, comment.commentable] }
      row(:content) { textile comment.content }
      row(:commentable_type)
      row(:created_at)
      row(:updated_at)
    end
  end

  action_item :except => :index do
    link_to 'Show Thread', comment.commentable
  end

  batch_action :destroy, :confirm => 'Are you sure you want to delete all of these?' do |selection|
    Comment.find(selection).each &:destroy

    flash[:notice] = 'Comments were successfully destroyed.'
    redirect_to admin_comments_path
  end
end
