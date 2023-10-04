defmodule AssetTracker do
  @moduledoc """
  Documentation for `AssetTracker`.
  """

  alias AssetTracker.UseCases.AddPurchaseUseCase
  alias AssetTracker.UseCases.AddSellUseCase
  alias AssetTracker.UseCases.CalcValuationUseCase

  @type build_attrs :: %{
          asset_tracker: String.t(),
          symbol: String.t(),
          settle_date: NaiveDateTime.t(),
          quantity: Integer.t(),
          unit_price: Decimal.t()
        }

  @spec add_purchase(params :: build_attrs()) :: {:ok, AssetTracker.Entities.Asset.t()}
  defdelegate add_purchase(params), to: AddPurchaseUseCase, as: :execute

  @spec add_sale(params :: build_attrs()) :: {:ok, Map.t()}
  defdelegate add_sale(params), to: AddSellUseCase, as: :execute

  @spec calc_valuation(String.t(), String.t(), Integer.t()) :: {:ok, Decimal.t()}
  defdelegate calc_valuation(symbol, asset, unit_price), to: CalcValuationUseCase, as: :execute
end
