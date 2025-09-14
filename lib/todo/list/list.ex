defmodule Todo.List do
  use GenServer

  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %__MODULE__{}, &add_entry(&2, &1))
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.next_id,
        entry
      )

    %Todo.List{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def get_entry_by_id(todo_list, entry_id) do
    MultiDict.get(todo_list.entries, entry_id)
  end

  def update_entry(todo_list, entry_id, new_date) do
    updated_entries = MultiDict.update(todo_list.entries, entry_id, &Map.put(&1, :date, new_date))
    %Todo.List{todo_list | entries: updated_entries}
  end

  def remove_entry(todo_list, entry_id) do
    updated_entries = MultiDict.remove(todo_list.entries, entry_id)
    %Todo.List{todo_list | entries: updated_entries}
  end
end
