defmodule MyloansApi.Model.AccessToken do
  alias MyloansApi.Model
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  @default_expire_seconds 3600*24

  schema "access_tokens" do
    field :token, :string
    field :session_key, :string
    field :last_valid, :utc_datetime
    belongs_to :user, Model.User
  end

  def find({:session_key, session_key}) do
    from(a in Model.AccessToken, where: a.session_key == ^session_key)
    |> MyloansApi.Repo.one
  end

  def find({:token, token}) do
    from(a in Model.AccessToken, where: a.token == ^token)
    |> MyloansApi.Repo.one
  end

  def find({:user_id, user_id}) do
    from(a in Model.AccessToken, where: a.user_id == ^user_id)
    |> MyloansApi.Repo.one
  end

  def find({:id, id}) do
    from(a in Model.AccessToken, where: a.id == ^id)
    |> MyloansApi.Repo.one
  end

  def find(id) when is_number(id), do: find({:id, id})

  def remove_expired_tokens do
    expire_threshold = expire_threshold_date()
    from(a in Model.AccessToken,
      where: a.last_valid < ^expire_threshold)
    |> MyloansApi.Repo.delete_all()
  end

  def refresh(session_key) do
    find({:session_key, session_key})
    |> refresh_access_token()
  end

  defp refresh_access_token(nil), do: nil
  defp refresh_access_token(%Model.AccessToken{} = access_token) do
    access_token
    |> update_valid_changeset()
    |> MyloansApi.Repo.update!()
  end

  def expire_threshold_date() do
    DateTime.utc_now()
    |> DateTime.add(-@default_expire_seconds, :second)
  end

  def new_changeset(token, session_key, %Model.User{id: user_id}) do
    %Model.AccessToken{}
    |> cast(%{token: token, session_key: session_key, last_valid: DateTime.utc_now(), user_id: user_id}, [:token, :session_key, :last_valid, :user_id])
  end

  def update_valid_changeset(access_token) do
    access_token
    |> cast(%{last_valid: DateTime.utc_now()}, [:last_valid])
  end
end
