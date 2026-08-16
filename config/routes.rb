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

    # Editable copy of the public site.
    resource :content, only: %i[show update], controller: :content
    resources :faqs, path: "faqs" do
      member { patch :toggle }
    end
    resources :differentials, path: "diferenciales" do
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

  # ── Demo portal ────────────────────────────────────────────────────────────
  # Página de entrada para la demo con clientes: una grilla que enlaza a cada
  # edición pública (/v1 … /v4). Mantiene un /robots.txt de raíz que apunta al
  # sitemap de la edición principal.
  root to: "portal#show"
  get "robots.txt", to: "portal#robots", as: :portal_robots, format: false

  # ── Public site (Site1) ────────────────────────────────────────────────────
  # Spanish, slug-based URLs. Everything here is read-only except the enquiry
  # form; nothing under this scope can reach an admin controller. Serves under
  # /v1 so the demo portal can own "/" like the other editions.
  scope "/v1", module: :site, as: :site do
    get "/", to: "home#show", as: :root

    resources :vehicles, path: "vehiculos", only: %i[index show], param: :slug do
      member { post :whatsapp_click }
    end

    resources :offers, path: "ofertas", only: :index

    get "nosotros",            to: "pages#about",   as: :about
    get "preguntas-frecuentes", to: "pages#faqs",   as: :faqs
    get "contacto",            to: "pages#contact", as: :contact

    resources :inquiries, path: "consultas", only: :create

    # Rutas literales: los buscadores esperan exactamente /sitemap.xml y
    # /robots.txt, y así los helpers generan la URL con extensión (con
    # `defaults: { format: :xml }` Rails la omite por ser el valor por defecto).
    get "sitemap.xml", to: "sitemaps#show", as: :sitemap, format: false, defaults: { format: :xml }
    get "robots.txt",  to: "sitemaps#robots", as: :robots, format: false
  end

  # ── Segunda web pública (Site2) ────────────────────────────────────────────
  # Convive con la anterior sobre el mismo dominio de datos. Tiene sus propias
  # acciones: nada de acá entra a Site:: ni al admin.
  #
  # No publica sitemap ni robots — esos siguen siendo del sitio principal
  # mientras Site2 sea una versión en evaluación (config.x.site2.preview).
  scope "/v2", module: :site2, as: :site2 do
    get "/", to: "home#show", as: :root

    resources :vehicles, path: "vehiculos", only: %i[index show], param: :slug do
      member { post :whatsapp_click }
    end

    resources :offers, path: "ofertas", only: :index

    get "nosotros",             to: "pages#about",   as: :about
    get "preguntas-frecuentes", to: "pages#faqs",    as: :faqs
    get "contacto",             to: "pages#contact", as: :contact

    resources :inquiries, path: "consultas", only: :create
  end

  # ── Tercera web pública (Site3) ────────────────────────────────────────────
  # Misma regla que Site2: acciones propias, ningún cruce con Site:: ni Site2::,
  # y sin sitemap ni robots propios mientras sea una versión en evaluación.
  scope "/v3", module: :site3, as: :site3 do
    get "/", to: "home#show", as: :root

    resources :vehicles, path: "vehiculos", only: %i[index show], param: :slug do
      member { post :whatsapp_click }
    end

    resources :offers, path: "ofertas", only: :index

    get "nosotros",             to: "pages#about",   as: :about
    get "preguntas-frecuentes", to: "pages#faqs",    as: :faqs
    get "contacto",             to: "pages#contact", as: :contact

    resources :inquiries, path: "consultas", only: :create
  end

  # ── Cuarta web pública (Site4) ─────────────────────────────────────────────
  # Misma regla que Site2 y Site3: acciones propias, ningún cruce con Site::,
  # Site2:: ni Site3::, y sin sitemap ni robots propios mientras sea una
  # versión en evaluación.
  scope "/v4", module: :site4, as: :site4 do
    get "/", to: "home#show", as: :root

    resources :vehicles, path: "vehiculos", only: %i[index show], param: :slug do
      member { post :whatsapp_click }
    end

    resources :offers, path: "ofertas", only: :index

    get "nosotros",             to: "pages#about",   as: :about
    get "preguntas-frecuentes", to: "pages#faqs",    as: :faqs
    get "contacto",             to: "pages#contact", as: :contact

    resources :inquiries, path: "consultas", only: :create
  end
end
