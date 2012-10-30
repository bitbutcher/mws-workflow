class TasksController < ApplicationController

  def index
    @tasks = FeedTask.includes(:queue, :transaction, :dependencies).all
  end

end
