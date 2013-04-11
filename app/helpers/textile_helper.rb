require 'cgi'

module TextileHelper
  def textile string
    RedCloth.new(escape string).to_html.html_safe
  end

  def textile_as_plain string
    RedCloth.new(escape string).to_plain
  end

  private

  def escape text
    CGI.escapeHTML text
  end
end
