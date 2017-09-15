class V1::PeopleController < ApplicationController

  def update
    @manager = PeopleUpdater.new(params: params)

    if @manager.call
      render json: {
        persona:   @manager.people.first,
        registros: @manager.people.size
      },status: 200
    else
      bad_request
    end
  end

end
