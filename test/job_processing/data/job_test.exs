defmodule JobProcessing.JobTest do
  use ExUnit.Case, async: true

  alias JobProcessing.Data.Job

  @example_task_list [
    %{command: "touch /tmp/file1", name: "task-1"},
    %{
      command: "cat /tmp/file1",
      name: "task-2",
      requires: ["task-3"]
    },
    %{
      command: "echo 'Hello World!' > /tmp/file1",
      name: "task-3",
      requires: ["task-1"]
    },
    %{
      command: "rm /tmp/file1",
      name: "task-4",
      requires: ["task-2", "task-3"]
    }
  ]

  describe "create a job" do
    test "and succeed" do
      task1_attrs = %{name: "task1", command: "echo 'task1'"}
      task2_attrs = %{name: "task2", command: "echo 'task2'"}
      task3_attrs = %{name: "task3", command: "echo 'task3'"}
      assert {:ok, _job} = Job.create(%{tasks: [task1_attrs, task2_attrs, task3_attrs]})
    end

    @tag :wip
    test "and fail because the requires key doesn't specify a valid task name" do
      task1_attrs = %{name: "task1", command: "echo 'task1'", requires: ["task2"]}
      task2_attrs = %{name: "task2", command: "echo 'task2'", requires: ["task3"]}
      task3_attrs = %{name: "task3", command: "echo 'task3'", requires: ["non-existing-task"]}

      assert {:error,
              {:job_create,
               "Couldn't create job because: \"requires\" field specifies a task that doesn't exist"}} =
               Job.create(%{tasks: [task1_attrs, task2_attrs, task3_attrs]})
    end

    test "and fail because of an empty list" do
      assert {
               :error,
               {:job_create, "Couldn't create job because: %{tasks: [\"can't be blank\"]}"}
             } = Job.create(%{tasks: []})
    end
  end

  describe "sort tasks inside job" do
    test "and succeed" do
      assert {:ok, job} = Job.create(%{tasks: @example_task_list})
      assert {:ok, job} = Job.sort_tasks(job)

      assert job == %JobProcessing.Data.Job{
               tasks: [
                 %JobProcessing.Data.Task{
                   name: "task-1",
                   command: "touch /tmp/file1",
                   requires: []
                 },
                 %JobProcessing.Data.Task{
                   name: "task-3",
                   command: "echo 'Hello World!' > /tmp/file1",
                   requires: ["task-1"]
                 },
                 %JobProcessing.Data.Task{
                   name: "task-2",
                   command: "cat /tmp/file1",
                   requires: ["task-3"]
                 },
                 %JobProcessing.Data.Task{
                   name: "task-4",
                   command: "rm /tmp/file1",
                   requires: ["task-2", "task-3"]
                 }
               ]
             }
    end

    test "and fail because of a circular dependency" do
      task1_attrs = %{name: "task1", command: "echo 'task1'", requires: ["task2"]}
      task2_attrs = %{name: "task2", command: "echo 'task2'", requires: ["task1"]}
      task3_attrs = %{name: "task3", command: "echo 'task3'", requires: ["task1"]}
      assert {:ok, job} = Job.create(%{tasks: [task1_attrs, task2_attrs, task3_attrs]})

      assert {:error,
              {:job_sort_tasks, "tasks are unsortable. please check the \"requires\" key"}} =
               Job.sort_tasks(job)
    end
  end
end
