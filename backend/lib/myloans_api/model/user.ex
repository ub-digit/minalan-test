defmodule MyloansApi.Model.User do
  alias MyloansApi.Model
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :login, :string
    field :email, :string
    field :source_id, :string
    has_many :access_tokens, Model.AccessToken
  end

  def find_query({:source_id, source_id}), do: from(u in Model.User, where: u.source_id == ^source_id)
  def find_query({:email, email}), do: from(u in Model.User, where: u.email == ^email)
  def find_query({:login, login}), do: from(u in Model.User, where: u.login == ^login)
  def find_query(id) when is_number(id), do: from(u in Model.User, where: u.id == ^id)

  def find(param) do
    find_query(param)
    |> MyloansApi.Repo.one
    |> MyloansApi.Repo.preload([:access_tokens])
  end

  def new_changeset(params \\ %{}) do
    %Model.User{}
    |> cast(params, [:name, :login, :email, :source_id])
  end

  def update_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:id, :name, :login, :email])
  end

  def remap(nil), do: nil
  def remap(%Model.User{} = user) do
    %{
      login: user.login,
      email: user.email,
      name: user.name,
      source_id: user.source_id,
      id: user.id
    }
  end
end
