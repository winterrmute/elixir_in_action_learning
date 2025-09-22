defmodule Todo.Database do
  # use GenServer

  @moduledoc false
  @type worker_index :: 0..2
  @type worker_pid :: pid()
  @type t :: %__MODULE__{
          workers: %{worker_index() => worker_pid()}
        }
  defstruct workers: %{}

  @db_folder "./persist"
  @pool_size 3

  def start_link do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def store(key, data) do
    get_worker(key)
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    get_worker(key)
    |> Todo.DatabaseWorker.get(key)
  end

  defp get_worker(key), do: :erlang.phash2(key, @pool_size) + 1

  def file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
