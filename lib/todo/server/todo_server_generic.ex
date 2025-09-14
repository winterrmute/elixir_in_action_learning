defmodule Todo.Server.Generic do
  def start(callback_module) do
    case Process.whereis(:todo_generic_server) do
      nil ->
        pid =
          spawn(fn ->
            initial_state = callback_module.init()
            loop(callback_module, initial_state)
          end)

        Process.register(pid, :generic_server)

      _ ->
        {:error, :server_already_exists}
    end
  end

  def loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)

      {:error, message} ->
        IO.puts(message)
        loop(callback_module, current_state)
    end
  end

  def call(request) do
    send(:todo_generic_server, {:call, request, self()})

    receive do
      {:response, response} ->
        response

      {:error, reason} ->
        IO.puts("Error occured: #{reason}")
    end
  end

  def cast(request), do: send(:todo_generic_server, {:cast, request})
end
