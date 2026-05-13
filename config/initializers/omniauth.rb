# OmniAuth configuration
# Sets the full host URL for callbacks and proper redirect handling
OmniAuth.config.full_host = ENV.fetch('FRONTEND_URL', 'http://localhost:3000')

GOOGLE_OAUTH_SETUP_PROC = lambda do |env|
  strategy = env['omniauth.strategy']
  strategy.options[:client_id] = GlobalConfigService.load('GOOGLE_OAUTH_CLIENT_ID', nil)
  strategy.options[:client_secret] = GlobalConfigService.load('GOOGLE_OAUTH_CLIENT_SECRET', nil)
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, nil, nil, {
    provider_ignores_state: true,
    setup: GOOGLE_OAUTH_SETUP_PROC
  }
end
