defmodule JobProcessing.Data do
  @moduledoc """
  Helper macro module that provides common functionality for data modules.
  Maybe is not worth it for this small project, but it's a good practice
  """
  defmacro __using__(_args) do
    quote do
      @doc """
      A helper that transforms changeset errors into a map of messages.

          assert {:error, changeset} = Accounts.create_user(%{password: "short"})
          assert "password is too short" in errors_on(changeset).password
          assert %{password: ["password is too short"]} = errors_on(changeset)

      """
      @spec errors_on(Ecto.Changeset.t()) :: map()
      def errors_on(changeset) do
        Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
          Regex.replace(~r"%{(\w+)}", message, fn _, key ->
            opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
          end)
        end)
      end
    end
  end
end
