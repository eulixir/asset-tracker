defmodule AssetTracker.Services.HasAbleToSell do
  alias AssetTracker.Services.CalcBalance

  def run(to_sell_asset) do
    balance = CalcBalance.run(to_sell_asset.asset_tracker)

    operation_value = to_sell_asset.operation_value |> Decimal.mult(-1)

    case operation_value > balance do
      true -> {:error, "Insufficient balance for this operation"}
      false -> :ok
    end
  end
end
