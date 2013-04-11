module NotificationsHelper
  def format_notification n
    case n[:event]
      when :comment then format_comment n
      when :report  then format_report n
      when :revoke  then format_revoke n
      else 'Unknown notification.'
    end
  end

  private

  def format_comment n
    commentable = n[:type].classify.constantize.find_by_id n[:id]
    user        = User.find_by_id n[:by_id]

    format_notification_string n, "#{nick user} commented on #{object_reference commentable}"
  end

  def format_notification_string notification, string
    ago = time_ago_in_words notification[:date]
    "#{string} #{ago} ago.".html_safe
  end

  def format_report n
    game   = Game.find_by_id n[:id]
    user   = User.find_by_id n[:by_id]
    result = n[:type].to_s.titleize

    format_notification_string n, "#{result} in #{object_reference game} was reported by #{nick user}"
  end

  def format_revoke n
    game = Game.find_by_id n[:id]
    user = User.find_by_id n[:by_id]

    format_notification_string n, "#{nick user} revoked #{object_reference game}"
  end

  def object_reference object
    object ? link_to_object(object) : content_tag(:span, 'Deleted', :class => 'deleted')
  end
end
