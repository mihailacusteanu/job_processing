defmodule JobProcessing.JobTest do
  use ExUnit.Case, async: true

  alias JobProcessing.Data.Job

  describe "create a job" do
    test "and succeed" do
      task1_attrs = %{name: "task1", command: "echo 'task1'"}
      task2_attrs = %{name: "task2", command: "echo 'task2'"}
      task3_attrs = %{name: "task3", command: "echo 'task3'"}
      assert {:ok, _job} = Job.create(%{tasks: [task1_attrs, task2_attrs, task3_attrs]})
    end

    test "and fail because of an empty list" do
      assert {
               :error,
               {:create_job, "Couldn't create job because: %{tasks: [\"can't be blank\"]}"}
             } = Job.create(%{tasks: []})
    end
end
