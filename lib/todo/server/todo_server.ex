defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  # Interface functions
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def init(name) do
    IO.puts("Starting to-do server for #{name}")
    {:ok, {name, nil}, {:continue, :init}}
  end

  def handle_continue(:init, {name, nil}) do
    {:noreply, {name, Todo.Database.get(name) || Todo.List.new()}, @expiry_idle_timeout}
  end

  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}, @expiry_idle_timeout}
  end

  def handle_call({:entries, nil}, _, {name, todo_list}) do
    {:reply, todo_list, {name, todo_list}, @expiry_idle_timeout}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}, @expiry_idle_timeout}
  end

  def via_tuple(name) do
    Todo.Registry.via_tuple({__MODULE__, name})
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date \\ nil) do
    GenServer.call(todo_server, {:entries, date})
  end
end
