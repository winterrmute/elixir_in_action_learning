defmodule Todo.Cache do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    IO.puts("cache starting")
    Todo.Database.start()
    {:ok, %{}}
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
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
        # and add it to the list
        {:reply, new_server, Map.put(todo_servers, todo_list_name, new_server)}
    end
  end
end
