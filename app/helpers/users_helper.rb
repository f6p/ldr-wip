module UsersHelper
  def country_flag user
    filename = Country.filename user.country
    image_tag "flags/#{filename}", :alt => ''
  end

  def nick user, path = nil
    return user unless user.registered?
    link_to "#{user}", path || user
  end

  def standings_item index, &block
    options = (last_in_row? index) ? {:class => :last} : {}
    content_tag(:li, options) { block.call }
  end

  def user_types
    return 'Competitive', 'Casual'
  end

  private

  def last_in_row? index
    (index + 1) % 3 == 0
  end
end
