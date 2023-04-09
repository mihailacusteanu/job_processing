defmodule JobProcessingWeb.TaskControllerTest do
  use JobProcessingWeb.ConnCase

  @task_list %{
    "tasks" => [
      %{
        "name" => "task-1",
        "command" => "touch /tmp/file1"
      },
      %{
        "name" => "task-2",
        "command" => "cat /tmp/file1",
        "requires" => [
          "task-3"
        ]
      },
      %{
        "name" => "task-3",
        "command" => "echo 'Hello World!' > /tmp/file1",
        "requires" => [
          "task-1"
        ]
      },
      %{
        "name" => "task-4",
        "command" => "rm /tmp/file1",
        "requires" => [
          "task-2",
          "task-3"
        ]
      }
    ]
  }

  @response %{
    "tasks" => [
      %{
        "name" => "task-1",
        "command" => "touch /tmp/file1"
      },
      %{
        "name" => "task-3",
        "command" => "echo 'Hello World!' > /tmp/file1"
      },
      %{
        "name" => "task-2",
        "command" => "cat /tmp/file1"
      },
      %{
        "name" => "task-4",
        "command" => "rm /tmp/file1"
      }
    ]
  }

  test "POST /job/sort empty task list", %{conn: conn} do
    conn = post(conn, ~p"/job/sort", %{"tasks" => []})

    assert %{
             "error" => "Couldn't create job because: %{tasks: [\"can't be blank\"]}"
           } == json_response(conn, 200)
  end

  test "POST /job/sort task_list", %{conn: conn} do
    conn = post(conn, ~p"/job/sort", @task_list)
    assert @response == json_response(conn, 200)
  end

  test "POST /job/sort task_list and get bash_script", %{conn: conn} do
    params = Map.merge(@task_list, %{return_bash_script: true})
    conn = post(conn, ~p"/job/sort", params)

    reponse_with_bash_script =
      Map.merge(
        @response,
        %{
          "bash_script" => """
          #!/usr/bin/env bash
          touch /tmp/file1
          echo 'Hello World!' > /tmp/file1
          cat /tmp/file1
          rm /tmp/file1\
          """
        }
      )

    assert reponse_with_bash_script == json_response(conn, 200)
  end

  test "POST /job/sort an unsortable list of tasks", %{conn: conn} do
    unsortable_task_list = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => ["task-2"]
        },
        %{
          "name" => "task-2",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => ["task-1"]
        }
      ]
    }

    conn = post(conn, ~p"/job/sort", unsortable_task_list)

    assert %{
             "error" => "tasks are unsortable. please check the \"requires\" key"
           } == json_response(conn, 200)
  end
end
