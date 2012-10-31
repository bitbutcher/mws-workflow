class TasksController < ApplicationController

  def index
    @tasks = FeedTask.includes(:queue, :transaction, :feed_task_dependencies).order(:created_at).all

    respond_to do |format|
      format.html
      format.json do 
        render json: @tasks
      end
    end
  end

end
