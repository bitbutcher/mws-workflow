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

  def show
    @task = FeedTask.find params[:id]
    render json: @task.as_json(include_body: true)
  end

end
