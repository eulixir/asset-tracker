defmodule AssetTracker.Services.HasAbleToSell do
  @moduledoc """
  A module for checking if there are sufficient assets to sell.

  This module provides functionality to check if there are sufficient assets to perform a sell operation. It ensures that the quantity of assets to be sold is available in the database.

  ## Usage

  You can use the `run/1` function to check if there are sufficient assets to sell a specific asset.

  ```elixir
    selling_asset = %Asset{
    asset_tracker: "APPL",
    symbol: "USD",
    settle_date: ~N[2023-10-04 14:30:00],
    quantity: 5,
    unit_price: Decimal.new("160.00")
  }

  result = AssetTracker.Services.HasAbleToSell.run(selling_asset)
  """
  alias AssetTracker.Entities.Asset
  alias AssetTracker.Services.CalcQuantity

  @error_msg "Insufficient assets for this operation"

  @spec run(selling_asset :: Asset.t()) :: :ok | {:error, String.t()}
  def run(selling_asset) when selling_asset.quantity <= 0,
    do: {:error, "The least you can do is more than one"}

  def run(selling_asset) do
    case CalcQuantity.run(selling_asset.asset_tracker) do
      {:ok, quantity} ->
        can_sell?(selling_asset, quantity)

      {:error, error} ->
        {:error, error}
    end
  end

  defp can_sell?(selling_asset, quantity) do
    case selling_asset.quantity > quantity do
      true -> {:error, @error_msg}
      false -> :ok
    end
  end
end
