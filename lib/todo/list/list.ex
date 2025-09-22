defmodule Todo.List do
  use GenServer

  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    IO.puts("new list creating")
    Enum.reduce(entries, %__MODULE__{}, &add_entry(&2, &1))
  end

  def add_entry(%__MODULE__{next_id: next_id} = todo_list, entry) do
    entry = Map.put(entry, :id, next_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.next_id,
        entry
      )

    %Todo.List{todo_list | entries: new_entries, next_id: next_id + 1}
  end

  def entries(%__MODULE__{entries: entries}, nil) do
    entries
  end

  def entries(%__MODULE__{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry.name end)
  end

  def get_entry_by_id(todo_list, entry_id) do
    MultiDict.get(todo_list.entries, entry_id)
  end

  def update_entry(
        %__MODULE__{entries: entries} = todo_list,
        entry_id,
        new_date
      ) do
    updated_entries = MultiDict.update(entries, entry_id, &Map.put(&1, :date, new_date))
    %Todo.List{todo_list | entries: updated_entries}
  end

  def remove_entry(%__MODULE__{entries: entries} = todo_list, entry_id) do
    updated_entries = MultiDict.remove(entries, entry_id)
    %Todo.List{todo_list | entries: updated_entries}
  end
end
