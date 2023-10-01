defmodule AssetTracker.Services.CalcBalance do
  alias AssetTracker.Database

  @spec run(String.t()) :: Decimal.t()
  def run(asset_name) do
    assets = Database.lookup("assets")

    Enum.reduce(assets, 0, fn %{operation_value: operation_value, asset_tracker: name}, acc ->
      case name === asset_name do
        true -> Decimal.add(operation_value, acc)
        false -> acc
      end
    end)
  end
end
