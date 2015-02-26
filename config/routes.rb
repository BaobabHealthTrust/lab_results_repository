Rails.application.routes.draw do

  root "process#get_labs"

  get "/update_labs_only" => "process#update_labs_only"

  post "/update_labs_only" => "process#update_labs_only"

  get "/get_specific_patient_labs_by_specimen_id/:id" => "process#get_specific_labs"

  get "/get_specific_labs/:id" => "process#get_specific_labs"

  get "/get_patient_labs_by_npid/:id" => "process#get_labs"

  get "/get_labs/:id" => "process#get_labs"

  post '/save_labs' => "process#create_or_update_labs"

end
