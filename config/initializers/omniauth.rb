OmniAuth.config.logger = Rails.logger
OmniAuth.config.failure_raise_out_environments = []

if defined?(MEMCACHE_SERVERS)
  require "openid/store/memcache"

  openid_store = OpenID::Store::Memcache.new(Dalli::Client.new(MEMCACHE_SERVERS, :namespace => "rails"))
else
  require "openid/store/filesystem"

  openid_store = OpenID::Store::Filesystem.new(Rails.root.join("tmp/openids"))
end

openid_options = { :name => "openid", :store => openid_store }
google_options = { :name => "google", :scope => "email", :access_type => "online" }

if defined?(GOOGLE_OPENID_REALM)
  google_options[:openid_realm] = GOOGLE_OPENID_REALM
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid, openid_options
  provider :google_oauth2, GOOGLE_AUTH_ID, GOOGLE_AUTH_SECRET, google_options if defined?(GOOGLE_AUTH_ID)
end

# Pending fix for: https://github.com/intridea/omniauth/pull/795
module OmniAuth
  module Strategy
    def mock_callback_call_with_origin
      @env["omniauth.origin"] = session["omniauth.origin"]

      mock_callback_call_without_origin
    end

    alias_method_chain :mock_callback_call, :origin
  end
end
