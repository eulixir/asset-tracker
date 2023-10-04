defmodule AssetTracker.Services.CalcBalance do
  @moduledoc """
  A module for calculating the balance of assets.

  This module provides functionality to calculate the total balance of assets based on the provided asset name.
  It sums up the operation values of all assets with matching asset names in the database.

  ## Usage

  You can use the `run/1` function to calculate the total balance of assets for a specific asset name.

  ```elixir
  asset_name = "BTC"

  {:ok, balance} = AssetTracker.Services.CalcBalance.run(asset_name)
  """

  alias AssetTracker.Database

  @spec run(String.t()) :: {:ok, Decimal.t()} | {:error, String.t()}
  def run(asset_name) do
    "assets"
    |> Database.lookup()
    |> Enum.reduce(0, &calc_balance(&1, asset_name, &2))
    |> build_response()
  end

  defp calc_balance(asset, asset_name, acc) do
    case asset.asset_tracker === asset_name do
      true -> Decimal.add(asset.operation_value, acc)
      false -> acc
    end
  end

  defp build_response(balance) when balance > 0, do: {:ok, balance}

  defp build_response(_), do: {:error, "Asset not found"}
end
