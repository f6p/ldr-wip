require 'cgi'
require 'date'

module Ladder
  class DateFormatter
    attr_reader :date

    def initialize date
      @date = date.to_datetime
    end

    def to_param
      return nil unless @date.valid?
      @date.strftime DateFormatter.date_format
    end

    def to_s
      @date.strftime DateFormatter.date_format
    end

    def to_url
      return DateFormatter.base_url unless @date.valid?

      date  = CGI.escape to_param
      order = CGI.escape '<='

      "#{DateFormatter.base_url}?reportdate=#{date}&reporteddirection=#{order}"
    end

    def self.base_url
      "#{URL}gamehistory.php"
    end

    def self.date_format
      '%Y-%m-%d %H:%M:%S'
    end
  end
end
