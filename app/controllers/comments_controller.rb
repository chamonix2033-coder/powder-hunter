class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_resort
  before_action :set_comment, only: [ :update, :destroy ]

  def create
    @comment = @resort.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to resort_path(@resort, anchor: "comments"), notice: "コメントを投稿しました"
    else
      redirect_to resort_path(@resort, anchor: "comments"), alert: @comment.errors.full_messages.join("、")
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to resort_path(@resort, anchor: "comment-#{@comment.id}"), notice: "コメントを更新しました"
    else
      redirect_to resort_path(@resort, anchor: "comment-#{@comment.id}"), alert: @comment.errors.full_messages.join("、")
    end
  end

  def destroy
    @comment.destroy
    redirect_to resort_path(@resort, anchor: "comments"), notice: "コメントを削除しました"
  end

  private

  def set_resort
    @resort = SkiResort.find(params[:resort_id])
  end

  def set_comment
    @comment = current_user.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to resort_path(@resort), alert: "コメントが見つかりません"
  end

  def comment_params
    params.require(:comment).permit(:body, :url)
  end
end
