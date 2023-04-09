defmodule JobProcessing.Data.TaskTest do
  use ExUnit.Case, async: true

  alias JobProcessing.Data.Task

  describe "create/1 task " do
    test "with valid data" do
      assert {:ok, %Task{}} = Task.create(%{name: "Task 1", command: "echo 'hello world'"})
    end

    test "with invalid data - command not field not specified" do
      assert {:error,
              {:task_create,
               "couldn't create task because: %{command: [\"can't be blank\"], name: [\"is invalid\"]}"}} =
               Task.create(%{name: 1})
    end

    test "with invalid data - command not field is integer " do
      assert {:error,
              {:task_create, "couldn't create task because: %{command: [\"is invalid\"]}"}} =
               Task.create(%{name: "Task 1", command: 1})
    end
  end
end
