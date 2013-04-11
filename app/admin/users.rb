ActiveAdmin.register User do
  actions :index, :show, :edit, :update

  config.per_page = 20

  filter :rating
  filter :nick
  filter :created_at
  filter :current_sign_in_at

  scope 'All', :default => true do |users|
    users.unscoped.registered.order 'current_sign_in_at DESC'
  end
  scope(:admins)
  scope(:banned)

  controller do
    before_filter :raise_if_unregistered, :except => :index

    private

    def raise_if_unregistered
      raise ActiveRecord::RecordNotFound unless resource.registered?
    end
  end

  form do |f|
    f.inputs  :email, :admin, :banned
    f.buttons :submit, :cancel
  end

  index :download_links => false do
    column(:rating) { |u| u.visible_rating }
    column(:nick) { |u| nick u, admin_user_path(u) }
    column(:admin)
    column(:banned)
    column(:created_at)
    column(:current_sign_in_at)

    default_actions
  end

  show :title => :nick do |user|
    attributes_table do
      row(:avatar) { avatar user }
      row(:rating) { rating_with_interval user }
      row(:kind)
      row(:admin)
      row(:banned)
      row(:created_at)
      row(:current_sign_in_at)
    end
  end

  action_item :except => :index do
    link_to 'Show User', user
  end
end
