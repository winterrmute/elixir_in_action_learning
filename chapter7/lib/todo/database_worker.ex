defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
  end

  @impl GenServer
  def init(db_folder) do
    File.mkdir_p!(db_folder)
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_folder) do
    db_folder
    |> Path.join(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    data =
      case File.read(Path.join(db_folder, key)) do
        {:ok, content} -> :erlang.binary_to_term(content)
        _ -> nil
      end

    {:reply, data, db_folder}
  end
end
