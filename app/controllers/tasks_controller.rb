class TasksController < ApplicationController

  def index
    @tasks = FeedTask.includes(:queue, :transaction, :dependencies).order('transaction_id, index, created_at').all

    respond_to do |format|
      format.html
      format.json { render json: @tasks.to_json(include: [ :queue, :transaction, :dependencies ], methods: [ :state ]) }
    end
  end


end
