defmodule JobProcessingWeb.Api.JobController do
  use JobProcessingWeb, :controller
  alias JobProcessing.Data.Job

  def sort(conn, params) do
    with {:ok, job} <- Job.create(%{tasks: params["tasks"]}),
         {:ok, job} <- Job.sort_tasks(job) do
      build_response(conn, job, params)
    else
      {:error, {_error_atom, error_message}} ->
        json(conn, %{error: error_message})
    end
  end

  ####################### PRIVATE FUNCTIONS #######################
  defp build_response(conn, job, %{"return_bash_script" => true}) do
    response =
      job
      |> Map.from_struct()
      |> Map.put("bash_script", Job.dump_to_bash_script(job))

    json(conn, response)
  end

  defp build_response(conn, job, _), do: json(conn, job)
end
