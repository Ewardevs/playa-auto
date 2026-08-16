Rails.application.routes.draw do
  # Authentication. Registration is deliberately disabled: accounts are created
  # by a Super Admin from the users module, never self-served.
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "ingresar",
               sign_out: "salir",
               password: "contrasena"
             }

  namespace :admin do
    get "/", to: "dashboard#show", as: :root

    resource :dashboard, only: :show, controller: :dashboard

    resources :vehicles do
      member do
        patch :status
        post  :duplicate
        patch :archive
        patch :restore
      end

      resources :images, only: %i[create destroy], controller: :vehicle_images do
        collection { patch :reorder }
        member     { patch :main }
      end
    end

    resources :brands do
      member { patch :toggle }
    end

    resources :vehicle_models, path: "modelos" do
      member { patch :toggle }
      # Feeds the brand → model dependent select via Turbo.
      collection { get :options }
    end

    resources :categories, path: "categorias" do
      member { patch :toggle }
    end

    resources :offers, path: "ofertas" do
      member { patch :toggle }
    end

    resources :inquiries, path: "consultas", except: %i[new create] do
      member { patch :status }
    end

    # Editable copy of the future public site.
    resource :content, only: %i[show update], controller: :content
    resources :faqs, path: "faqs" do
      member { patch :toggle }
    end

    # Company configuration — the single source of truth for company data.
    resource :settings, only: %i[show update], controller: :settings

    resources :users, path: "usuarios" do
      member do
        patch :toggle
        post  :reset_password
      end
    end

    resources :audit_logs, path: "auditoria", only: :index

    # Own account: profile details and password change.
    resource :profile,  only: %i[show update]
    resource :password, only: %i[edit update], controller: :passwords
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # The public site will take over "/" later; for now the admin panel is the app.
  root to: redirect("/admin")
end
