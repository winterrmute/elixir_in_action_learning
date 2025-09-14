defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")
    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()

    alice = Todo.Cache.server_process(cache, "alice")
    Todo.List.put(alice, %{date: ~D[2025-10-08], title: "dentist"})

    entries = Todo.List.entries(alice)
    assert %{1 => %{date: ~D[2025-10-08], id: 1, title: "dentist"}} = entries
  end
end
