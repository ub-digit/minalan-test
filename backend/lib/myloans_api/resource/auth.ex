defmodule MyloansApi.Resource.Auth do
  def authenticate(%{"cardnumber" => cardnumber, "password" => password, "provider" => "koha"}),
    do: MyloansApi.Resource.Auth.Koha.authenticate(cardnumber, password)
  def authenticate(%{"ticket" => ticket, "service" => service, "provider" => "cas"}),
    do: MyloansApi.Resource.Auth.CAS.authenticate(ticket, service)
  def authenticate(%{"code" => code, "provider" => "github"}),
    do: MyloansApi.Resource.Auth.Github.authenticate(code)
  def authenticate(%{"code" => code, "provider" => "GU"}),
    do: MyloansApi.Resource.Auth.GU.authenticate(code)
end
