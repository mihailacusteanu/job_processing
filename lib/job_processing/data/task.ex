defmodule JobProcessing.Data.Task do
  @moduledoc """
  Module that represents a task and it's mere purpose is to provide a way to validate data
  """
  use Ecto.Schema
  use JobProcessing.Data

  @required_fileds ~w(name command)a
  @optional_fields ~w()a

  @primary_key false
  embedded_schema do
    field :name, :string
    field :command, :string
  end

  @doc """
  Creates a task with the given attributes.
  """
  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, {:create_task, String.t()}}
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        task = Ecto.Changeset.apply_changes(changeset)
        {:ok, task}

      %Ecto.Changeset{valid?: false} = changeset ->
        errors = errors_on(changeset)
        {:error, {:create_task, "couldn't create task because: #{inspect(errors)}"}}
    end
  end

  @doc """
  Creates a changeset based on the `struct` and `params`.
  """
  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = task, attrs \\ %{}) do
    task
    |> Ecto.Changeset.cast(attrs, @required_fileds ++ @optional_fields)
    |> Ecto.Changeset.validate_required(@required_fileds)
  end
end
