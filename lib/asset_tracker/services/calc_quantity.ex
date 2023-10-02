defmodule AssetTracker.Services.CalcQuantity do
  alias AssetTracker.Database

  @spec run(String.t()) :: Decimal.t()
  def run(asset_name) do
    assets = Database.lookup("assets")

    Enum.reduce(assets, 0, fn %{quantity: quantity, asset_tracker: name}, acc ->
      case name === asset_name do
        true -> quantity + acc
        false -> acc
      end
    end)
  end
end
