defmodule Todo.Database do
  use GenServer

  @moduledoc false
  @type worker_index :: 0..2
  @type worker_pid :: pid()
  @type t :: %__MODULE__{
          workers: %{worker_index() => worker_pid()}
        }
  defstruct workers: %{}

  @db_folder "./persist"

  def start do
    IO.puts("database starting")
    GenServer.start(__MODULE__, nil, name: :database_server)
  end

  def store(key, data) do
    get_worker(key)
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    IO.puts("get #{key}")

    get_worker(key)
    |> Todo.DatabaseWorker.get(key)
  end

  defp get_worker(key), do: :database_server |> GenServer.call({:choose_worker, key})

  @impl GenServer
  def init(_) do
    IO.puts("worker starting")

    worker_pids =
      Enum.reduce(0..2, %{}, fn key, acc ->
        {:ok, worker_pid} = Todo.DatabaseWorker.start(@db_folder)
        Map.put(acc, key, worker_pid)
      end)

    IO.puts("worker stated: #{inspect(worker_pids)}")

    # {:ok, %Todo.Database{workers: worker_pids}}
    {:ok, worker_pids}
  end

  @impl GenServer
  # def handle_call({:choose_worker, key}, _, %Todo.Database{workers: worker_pids} = state) do
  def handle_call({:choose_worker, key}, _, state) do
    {:reply, Map.get(state, :erlang.phash2(key, 3)), state}
  end

  def file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
