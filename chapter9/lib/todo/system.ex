defmodule Todo.System do
  use Supervisor

  def start_link do
    Supervisor.start_link(
      [
        Todo.Registry,
        Todo.Database,
        Todo.Cache
      ],
      strategy: :one_for_one
    )
  end

  def init(_) do
    Supervisor.start_link(
      [
        # Todo.Registry,
        # Todo.Database,
        Todo.Cache
      ],
      strategy: :one_for_one
    )
  end
end
