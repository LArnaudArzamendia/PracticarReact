if Rails.env.test?
  Rails.application.config.session_store :cookie_store, key: "_test_session"
end
