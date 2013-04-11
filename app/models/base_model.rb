class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  def set value, *attributes
    attributes.each { |a| send "#{a}=", value }
  end

  def strip *attributes
    attributes.each { |a| send "#{a}=", send(a).to_s.strip }
  end

  def self.distinct c
    pluck(c).uniq.reject &:nil?
  end
end
