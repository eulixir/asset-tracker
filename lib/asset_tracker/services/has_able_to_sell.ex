defmodule AssetTracker.Services.HasAbleToSell do
  alias AssetTracker.Services.CalcQuantity

  def run(selling_asset) do
    quantity = CalcQuantity.run(selling_asset.asset_tracker)

    case selling_asset.quantity > quantity do
      true -> {:error, "Insufficient assets for this operation"}
      false -> :ok
    end
  end
end
