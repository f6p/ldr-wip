class NewsController < ApplicationController
  def index
    page  = request.format == 'atom' ? 1 : params[:page]
    @news = News.paginate :page => page
  end

  def show
    @news = News.find params[:id]

    @commentable = @news
    @comment = Comment.new
  end
end
