defmodule MyloansApi.Resource.Setup do
  alias MyloansApi.Model.Translation
  alias MyloansApi.Model.Alert

  def fetch("translations") do
    Translation.all()
  end

  def fetch("settings") do
    %{
      "cas_login_url" => System.get_env("CAS_LOGIN_URL"),
      "alert_url" => System.get_env("ALERT_URL"),
      "external_title_url_en" => System.get_env("EXTERNAL_TITLE_URL_EN"),
      "external_title_url_sv" => System.get_env("EXTERNAL_TITLE_URL_SV"),
      "address_mandatory" => System.get_env("ADDRESS_MANDATORY"),
      "sso_provider" => System.get_env("SSO_PROVIDER"),
      "oauth2_authorize_endpoint" => System.get_env("OAUTH2_AUTHORIZE_ENDPOINT"),
      "oauth2_client_id" => System.get_env("OAUTH2_CLIENT_ID"),
      "oauth2_scope" => System.get_env("OAUTH2_SCOPE"),
    }
  end

  def fetch("alert") do
    Alert.get()
  end
end
