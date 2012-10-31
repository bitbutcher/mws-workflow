class BatteriesController < ApplicationController

  def index
    @batteries = Battery.order('id').all

    render json: @batteries
  end

end