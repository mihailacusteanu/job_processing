defmodule JobProcessing.Data.Job do
  @moduledoc """
  Module that represents a task and it's mere purpose is to provide a way to validate data
  """
  use Ecto.Schema
  use JobProcessing.Data

  alias JobProcessing.Data.Task

  @type job() :: __MODULE__
  @type task() :: Task

  @primary_key false
  embedded_schema do
    embeds_many :tasks, JobProcessing.Data.Task
  end

  @doc """
  Creates a job with the given attributes.
  """
  @spec create(job_attrs) :: result
        when result: {:ok, %__MODULE__{}} | {:error, {:job_create, String.t()}},
             job_attrs: %{
               required(:tasks) => list(task())
             }

  def create(attrs) do
    with %Ecto.Changeset{valid?: true} = changeset <- changeset(%__MODULE__{}, attrs),
         job <- Ecto.Changeset.apply_changes(changeset),
         :ok <- is_requires_field_valid(job.tasks) do
      {:ok, job}
    else
      %Ecto.Changeset{valid?: false} = changeset ->
        errors = errors_on(changeset)
        {:error, {:job_create, "Couldn't create job because: #{inspect(errors)}"}}

      {:error, {:job_create_requires_not_existing, reason}} ->
        {:error, {:job_create, reason}}
    end
  end

  @doc """
  Topological ordering the list of tasks returning the value of the "name" key in the map.
  The sorting is based on the :requires key which mention which tasks should
  be executed before current task

  ## Examples

  iex> task_list = %JobProcessing.Data.Job{tasks: [%{name: "task-1", command: "touch /tmp/file1", requires: []},%{name: "task-2", command: "cat /tmp/file1", requires: ["task-3"]}, %{name: "task-3", command: "echo 'Hello World!' > /tmp/file1", requires: ["task-1"]}, %{name: "task-4", command: "rm /tmp/file1", requires: ["task-2",  "task-3"]}]}
  iex> JobProcessing.Data.Job.sort_tasks(task_list)
  {:ok, %JobProcessing.Data.Job{ tasks: [ %{command: "touch /tmp/file1", name: "task-1", requires: []}, %{ command: "echo 'Hello World!' > /tmp/file1", name: "task-3", requires: ["task-1"] }, %{ command: "cat /tmp/file1", name: "task-2", requires: ["task-3"] }, %{ command: "rm /tmp/file1", name: "task-4", requires: ["task-2", "task-3"] } ] }}
  """
  @spec sort_tasks(job()) :: {:error, {:job_sort_tasks, String.t()}} | {:ok, job()}
  def sort_tasks(job) do
    tasks_list = job.tasks
    dg = :digraph.new()

    populate_digraph(dg, tasks_list)

    case :digraph_utils.topsort(dg) do
      false ->
        {:error, {:job_sort_tasks, "tasks are unsortable. please check the \"requires\" key"}}

      ordered_task_names ->
        tasks_map = Map.new(tasks_list, fn task -> {task.name, task} end)

        ordered_tasks =
          ordered_task_names
          |> Enum.map(fn task_name -> Map.fetch!(tasks_map, task_name) end)

        {:ok, %{job | tasks: ordered_tasks}}
    end
  end

  @doc """
  Dumps the job to a bash script returned as a string
  """
  @spec dump_to_bash_script(job()) :: bash_script
        when bash_script: String.t()
  def dump_to_bash_script(job) do
    "#!/usr/bin/env bash\n" <> Enum.map_join(job.tasks, "\n", & &1.command)
  end

  ####################### PRIVATE FUNCTIONS #######################

  @doc false
  defp changeset(blog, attrs) do
    blog
    |> Ecto.Changeset.cast(attrs, [])
    |> Ecto.Changeset.cast_embed(:tasks, required: true, into: JobProcessing.Data.Task)
  end

  @spec is_requires_field_valid(tasks) ::
          :ok | {:error, {:job_create_requires_not_existing, String.t()}}
        when tasks: list(task())
  defp is_requires_field_valid(tasks) do
    all_tasks_names_map =
      tasks
      |> Enum.reduce(%{}, fn task, acc -> Map.put(acc, task.name, true) end)

    tasks
    |> Enum.all?(fn task ->
      Enum.all?(task.requires, fn req ->
        all_tasks_names_map[req] == true
      end)
    end)
    |> case do
      true ->
        :ok

      false ->
        {:error,
         {:job_create_requires_not_existing,
          "Couldn't create job because: \"requires\" field specifies a task that doesn't exist"}}
    end
  end

  @spec populate_digraph(:digraph.graph(), list(task)) :: list(:ok)
  defp populate_digraph(dg, tasks_list) do
    Enum.map(tasks_list, fn task ->
      :digraph.add_vertex(dg, task.name, task)
      required_tasks = task.requires || []
      Enum.each(required_tasks, fn required_task -> add_task(dg, task.name, required_task) end)
    end)
  end

  @spec add_task(:digraph.graph(), String.t(), String.t()) :: :digraph.graph() | :ok
  defp add_task(dg, task, required_task) do
    :digraph.add_vertex(dg, required_task)
    :digraph.add_edge(dg, required_task, task)
  end
end
