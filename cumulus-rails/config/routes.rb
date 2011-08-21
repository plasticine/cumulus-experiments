Cumulus::Application.routes.draw do
  resources :metrics, :only => [:show, :aggregate] do
    member do
      get :aggregate
    end
  end
end
