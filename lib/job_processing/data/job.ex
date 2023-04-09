defmodule JobProcessing.Data.Job do
  @moduledoc """
  Module that represents a task and it's mere purpose is to provide a way to validate data
  """
  use Ecto.Schema
  use JobProcessing.Data

  alias JobProcessing.Data.Task

  @type list_of_maps :: list(map())
  @type job() :: __MODULE__
  @type task() :: Task

  @primary_key false
  embedded_schema do
    embeds_many :tasks, JobProcessing.Data.Task
  end

  @doc """
  Creates a job with the given attributes.
  """
  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, {:create_job, String.t()}}
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        job = Ecto.Changeset.apply_changes(changeset)
        {:ok, job}

      %Ecto.Changeset{valid?: false} = changeset ->
        errors = errors_on(changeset)
        {:error, {:create_job, "Couldn't create job because: #{inspect(errors)}"}}
    end
  end

  @doc false
  def changeset(blog, attrs) do
    blog
    |> Ecto.Changeset.cast(attrs, [])
    |> Ecto.Changeset.cast_embed(:tasks, required: true, into: JobProcessing.Data.Task)
  end

end
