ActiveAdmin.register Page do
  config.paginate   =  false
  config.sort_order = 'title'

  filter :title
  filter :created_at
  filter :updated_at

  scope :all, :default => true
  scope :menu

  index :download_links => false do
    column :title
    column :menu
    column :created_at
    column :updated_at

    default_actions
  end

  show :title => :title do |page|
    attributes_table do
      row(:body) { textile page.body }
      row(:menu)
      row(:created_at)
      row(:updated_at)
    end
  end

  action_item :except => :index do
    link_to 'Show Page', page
  end
end
