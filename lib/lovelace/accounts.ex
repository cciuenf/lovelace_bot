defmodule Lovelace.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Lovelace.Accounts.User
  alias Lovelace.Repo

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Retuns the list of students

  ## Examples

     iex> list_students()
     [%User{}, ...]
  """
  def list_students do
    from(u in User)
    |> where([u], fragment("? @> ?", u.roles, ^["student"]))
    |> Repo.all()
  end

  @doc """
  Retuns the list of admins

  ## Examples

     iex> list_admins()
     [%User{}, ...]
  """
  def list_admins do
    from(u in User)
    |> where([u], fragment("? @> ?", u.roles, ^["admin"]))
    |> Repo.all()
  end

  @doc """
  Retuns the list of professors

  ## Examples

     iex> list_professors()
     [%User{}, ...]
  """
  def list_professors do
    from(u in User)
    |> where([u], fragment("? @> ?", u.roles, ^["professor"]))
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by some params

  Returns {:error, :not_found} if The User does not exist.

  ## Examples

     iex> get_user_by(telegram_id: 123)
     %User{}

     iex> get_user_by(telegram_id: 456)
     {:error, :not_found}
  """
  def get_user_by(params) do
    params
    |> User.get_query()
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.user_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a professor.

  ## Examples

      iex> create_professor(%{field: value})
      {:ok, %User{}}

      iex> create_professor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_professor(attrs \\ %{}) do
    %User{}
    |> User.professor_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a student.

  ## Examples

      iex> create_student(%{field: value})
      {:ok, %User{}}

      iex> create_student(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student(attrs \\ %{}) do
    %User{}
    |> User.student_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.user_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user role.

  ## Examples

      iex> update_user_role(user, roles: ["student", "admin"])
      {:ok, %User{}}

      iex> update_user_role(user, roles: bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def update_user_role(%User{} = user, roles: roles) do
    user
    |> User.role_changeset(%{roles: roles})
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.user_changeset(user, attrs)
  end
end
