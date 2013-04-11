class CommentsController < ApplicationController
  before_filter :authenticate_user!

  load_resource :game
  load_resource :news
  load_and_authorize_resource :comment, :through => [:game, :news]

  def edit
    @commentable = find_commentable
    @comment = Comment.find params[:id]
  end

  def create
    @commentable = find_commentable

    @comment = @commentable.comments.build params[:comment]
    @comment.author = current_user

    if @comment.save
      redirect_to @commentable, :notice => 'Comment was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    @comment = Comment.find params[:id]

    if @comment.update_attributes params[:comment]
      redirect_to @comment.commentable, :notice => 'Comment was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @comment = Comment.find params[:id]
    @comment.destroy

    redirect_to @comment.commentable, :notice => 'Comment was successfully destroyed.'
  end

  private

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find value
      end
    end
  end
end
