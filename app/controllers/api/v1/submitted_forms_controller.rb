class Api::V1::SubmittedFormsController < ApplicationController


  def create
    data = params[:params].to_snake_keys.deep_symbolize_keys
    request_id = data[:request_id].to_s

    if request_id == 'test_request'
      request_id = 'test_request_' + rand.to_s
    end

    sf = SubmittedForm.find_by(request_id: request_id)
    if sf.present?
      render json: {
        data: {
          nodes: [],
          edges: [],
        },
        requestId: request_id
      }
    else
      sf = SubmittedForm.create(request_id: request_id)
      data[:sf_id] = sf.id
      next_package = SubmitForm::Main.run(data)
      render json: {
        data: {
          nodes: CamelizeKeys.run(next_package[:ui_items]),
          edges: CamelizeKeys.run(next_package[:ui_item_relations])
        },
        requestId: request_id
      }
    end
  end


  def soft_delete
    data = params[:params].to_snake_keys.deep_symbolize_keys
    client_id = data[:client_id].to_s
    request_id = data[:request_id].to_s
    extants_found = SoftDeleteSubmittedForm.run(client_id)
    if extants_found
      render json: {data: {}, requestId: request_id, clientId: client_id}
    else
      render json: {data: {}, requestId: nil} # so request is not removed from queue on front-end
    end
  end
end
