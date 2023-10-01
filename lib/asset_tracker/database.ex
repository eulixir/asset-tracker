defmodule AssetTracker.Database do
  def init() do
    :ets.new(:asset_tracker, [:public, :named_table])
    :ets.insert_new(:asset_tracker, {"assets", []})
    :ets.insert_new(:asset_tracker, {"sells", []})
  end

  def insert(table, attrs) do
    items = lookup(table)

    :ets.insert(:asset_tracker, {table, items ++ [attrs]})
  end

  def overwrite(table, value), do: :ets.insert(:asset_tracker, {table, value})

  def lookup(table) do
    [{_key, items}] = :ets.lookup(:asset_tracker, table)

    items
  end

  def reset() do
    :ets.insert(:asset_tracker, {"assets", []})
    :ets.insert_new(:asset_tracker, {"sells", []})
  end
end
