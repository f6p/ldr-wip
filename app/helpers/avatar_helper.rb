module AvatarHelper
  def avatar user, size = 100
    return gravatar_image user, size if user.email?
    default_avatar user, size
  end

  def default_avatar user, size = 100
    image_tag 'wesnoth.png', :alt => '', :size => "#{size}x#{size}"
  end

  private

  def gravatar user, size = 100
    hash = Digest::MD5.hexdigest user.email.downcase
    "https://secure.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  def gravatar_image user, size = 100
    image_tag gravatar(user, size), :alt => ''
  end
end
