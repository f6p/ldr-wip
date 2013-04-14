require 'cgi'

module TextileHelper
  def textile string
    str = RedCloth.new(string)
    str.filter_html = true
    str.to_html.html_safe
  end

  def textile_as_plain string
    str = RedCloth.new(string)
    str.filter_html = true
    str.to_plain
  end
end
