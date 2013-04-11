ActiveAdmin.register News do
  config.per_page   = 20
  config.sort_order = 'created_at DESC'

  filter :title
  filter :created_at
  filter :updated_at

  scope :all, :default => true

  index :download_links => false do
    column :title
    column :created_at
    column :updated_at

    default_actions
  end

  show :title => :title do |news|
    attributes_table do
      row(:body) { textile news.body }
      if news.issue
        row(:issue_by) { admin_nick news.issue.user }
      end
      row(:created_at)
      row(:updated_at)
    end
  end

  action_item :except => :index do
    link_to 'Show News', news
  end
end
