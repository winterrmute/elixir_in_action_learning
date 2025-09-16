defmodule Todo.Cache do
  use GenServer

  def start do
    {:ok, pid} = GenServer.start(__MODULE__, nil)
    pid
  end

  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    IO.puts("#{inspect(todo_servers)}")

    case Map.fetch(todo_servers, todo_list_name) do
      # if server found
      {:ok, todo_server} ->
        # send reply to the caller with the result
        {:reply, todo_server, todo_servers}

      # if not found
      :error ->
        # create new todo_server
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        IO.puts("new server created")
        # and add it to the list
        {:reply, new_server, Map.put(todo_servers, todo_list_name, new_server)}
    end
  end
end
