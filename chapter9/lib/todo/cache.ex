defmodule Todo.Cache do
  def start_link() do
    IO.puts("cache starting")

    DynamicSupervisor.start_link(
      strategy: :one_for_one,
      name: __MODULE__
    )
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  # Supervisor interface
  defp start_child(todo_list_name) do
    IO.puts("Starting server for #{todo_list_name}")

    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    )
  end
end
