defmodule MyloansApi.Resource.User do
  alias MyloansApi.Model
  import Ecto.Query

  def fetch_all() do
    from(u in Model.User)
    |> MyloansApi.Repo.all
  end

  def fetch_access_token(token) do
    from(a in Model.AccessToken,
      join: u in Model.User,
      on: a.user_id == u.id,
      where: a.token == ^token,
      preload: [user: u])
    |> MyloansApi.Repo.one
  end

  def fetch_user_from_session_key(nil), do: nil
  def fetch_user_from_session_key(session_key) do
    expire_threshold = Model.AccessToken.expire_threshold_date()
    from(u in Model.User,
      join: a in Model.AccessToken,
      on: a.user_id == u.id,
      where: a.session_key == ^session_key,
      where: a.last_valid >= ^expire_threshold,
      preload: [access_tokens: a])
    |> MyloansApi.Repo.one
  end

  def fetch_or_create(access_token, %{"name" => name, "login" => login, "email" => email, "source_id" => source_id} = params) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:userdata, fn repo, %{} ->
      Model.User.find({:source_id, source_id})
      |> case do
        %Model.User{} = user ->
          user
          |> Model.User.update_changeset(%{id: user.id, name: name, login: login, email: email})
          |> repo.update()
        _ -> {:ok, nil}
      end
    end)
    |> Ecto.Multi.run(:token, fn repo, %{} ->
      token = fetch_access_token(access_token)
      user = case token do
        %Model.AccessToken{} ->
          repo.update!(Model.AccessToken.update_valid_changeset(token))
          token.user
        _ ->
          session_key = generate_session_key()
          user = Model.User.find({:source_id, source_id})
          case user do
            %Model.User{} ->
              repo.insert!(Model.AccessToken.new_changeset(access_token, session_key, user))
              user
            _ ->
              user = repo.insert!(Model.User.new_changeset(params))
              repo.insert!(Model.AccessToken.new_changeset(access_token, session_key, user))
              user
          end
      end

      {:ok, user}
    end)
    |> MyloansApi.Repo.transaction()

    user = Model.User.find({:source_id, source_id})
    access_token = Model.AccessToken.find({:token, access_token})

    {user, access_token}
  end

  def refresh_token(session_key) do
    MyloansApi.Model.AccessToken.remove_expired_tokens()
    MyloansApi.Model.AccessToken.refresh(session_key)
  end

  def generate_session_key() do
    UUID.uuid4(:hex)
  end
end
