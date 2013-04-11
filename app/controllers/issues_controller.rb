class IssuesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @issue = Issue.new

    @issue.user          = current_user
    @issue.issuable_id   = issuable[:id]
    @issue.issuable_type = issuable[:type]

    @issue.save

    if Issue.exists? issuable[:type], issuable[:id]
      redirect_to issuable_object, :notice => 'Support request was successfully created.'
    else
      redirect_to issuable_object, :alert => 'Support request could not be created.'
    end
  end

  private

  def issuable_object
    issuable[:type].classify.constantize.find issuable[:id]
  end

  def issuable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return {:id => value.to_i, :type => $1.classify}
      end
    end
  end
end
