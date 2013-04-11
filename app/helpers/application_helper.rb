module ApplicationHelper
  def ago_in_words action, datetime
    "#{action} #{time_ago_in_words datetime} ago"
  end

  def error_explanation object
    return '' if object.errors.empty?

    messages = object.errors.full_messages.map { |msg| content_tag :li, msg }.join
    sentence = "#{pluralize object.errors.count, 'error'} prohibited data from being saved:"

    html = <<-HTML
      <div class="error_explanation">
        <h1>#{sentence}</h1>
        <ul>#{messages}</ul>
      </div >
    HTML

    html.html_safe
  end

  def logo options = {}
    link_to image_tag('logo.png', :alt => 'Ladder'), root_url
  end

  def manageable? object
    current_user.try(:admin) || can?(:manage, object)
  end
end
