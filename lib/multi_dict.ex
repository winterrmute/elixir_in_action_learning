defmodule MultiDict do
  def new, do: %{}

  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end

  def get(dict, key) do
    Map.get(dict, key, [])
  end

  def update(dict, entry_id, updater_fun) do
    case Map.fetch(dict, entry_id) do
      :error ->
        dict

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        Map.put(dict, new_entry.id, new_entry)
    end
  end

  def remove(dict, key) do
    case Map.has_key?(dict, key) do
      true ->
        Map.delete(dict, key)

      false ->
        dict
    end

    if Map.has_key?(dict, key) do
      Map.delete(dict, key)
    else
      dict
    end
  end
end
