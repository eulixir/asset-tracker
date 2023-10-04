defmodule AssetTracker.UseCases.CalcValuationUseCase do
  @moduledoc """
  A module for calculating asset valuation and corrected wallet balance.

  This module provides functionality for calculating the valuation of assets based on their symbol, name, and unit price. It also calculates the corrected wallet balance after processing assets.

  ## Usage

  You can use the `execute/3` function to calculate the valuation and corrected wallet balance for a given asset.

  ```elixir
  symbol = "USD"
  asset_name = "BTC"
  unit_price = Decimal.new("50000.00")

  {ok, balance} = AssetTracker.UseCases.CalcValuationUseCase.execute(symbol, asset_name, unit_price)
  """
  alias AssetTracker.Database

  def execute(symbol, asset_name, unit_price) do
    assets = Database.lookup("assets")

    default_balance = {Decimal.new(0), Decimal.new(0)}

    assets
    |> Enum.reduce(default_balance, fn asset, {balance, corrected_wallet} ->
      case asset.symbol == symbol && asset.asset_tracker == asset_name do
        true ->
          calc_valuation(asset, balance, unit_price, corrected_wallet)

        false ->
          {balance, corrected_wallet}
      end
    end)
    |> calc_corrected_wallet()
  end

  defp calc_corrected_wallet({balance, corrected_wallet}) do
    balance = Decimal.sub(corrected_wallet, balance)

    {:ok, balance}
  end

  defp calc_valuation(asset, balance, unit_price, corrected_wallet) do
    updated_operation_value = Decimal.add(asset.operation_value, balance)

    corrected_wallet =
      unit_price
      |> Decimal.new()
      |> Decimal.mult(asset.quantity)
      |> Decimal.add(corrected_wallet)

    {updated_operation_value, corrected_wallet}
  end
end
