defmodule AssetTracker.Services.CalcQuantity do
  @moduledoc """
  A module for calculating the total quantity of assets.

  This module provides functionality to calculate the total quantity of assets based on the provided asset name. It sums up the quantities of all assets with matching asset names in the database.

  ## Usage

  You can use the `run/1` function to calculate the total quantity of assets for a specific asset name.

  ```elixir
  asset_name = "BTC"

  {:ok, quantity} = AssetTracker.Services.CalcQuantity.run(asset_name)
  """
  alias AssetTracker.Database

  @spec run(String.t()) :: {:ok, Integer.t()} | {:error, String.t()}
  def run(asset_name) do
    "assets"
    |> Database.lookup()
    |> Enum.reduce(0, &calc_asset_quantity(&1, asset_name, &2))
    |> build_response()
  end

  defp calc_asset_quantity(asset, asset_name, acc) do
    case asset.asset_tracker === asset_name do
      true -> asset.quantity + acc
      false -> acc
    end
  end

  defp build_response(quantity) when quantity > 0, do: {:ok, quantity}

  defp build_response(_), do: {:error, "Asset not found"}
end
