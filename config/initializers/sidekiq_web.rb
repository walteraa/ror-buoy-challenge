# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq::Web.use Rack::Session::Cookie, secret: Rails.application.credentials.secret_key_base || 'd4b66f91a3c548f9a16db07c9f771521cf4237d05a8101f61c9248c6ea3d1e17b7d70f198e3cbb3f1f32ea2e9418a2199
'
