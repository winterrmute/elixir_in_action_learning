defmodule Todo.DatabaseTest do
  use ExUnit.Case

  test "store key in database" do
    Todo.Database.store("myKey", "mydata")
    :timer.sleep(50)
    assert Todo.Database.get("myKey") = "mydata"
  end
end
