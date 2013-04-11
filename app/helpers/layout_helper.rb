module LayoutHelper
  def menu_pages_list
    items = Page.menu.map { |p| content_tag :li, link_to_object(p) }
    content_tag :ul, raw(items.join), :class => 'pages'
  end

  def page_content &content
    css = "content #{params[:controller]}"
    content_tag :section, :class => css, &content
  end

  def title object
    @title = object ? "#{object}" : 'Ladder'
  end
end
