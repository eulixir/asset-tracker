defmodule AssetTracker.UseCases.AddPurchaseUseCase do
  @moduledoc """
  A module for adding asset purchase records to the database.

  This module provides functionality to add purchase records of assets to the database.
  It allows you to specify the attributes of the purchase, such as asset tracker name, symbol, settle date, quantity, and unit price.

  ## Usage

  You can use the `execute/1` function to add a purchase record to the database.

  ```elixir
  attrs = %{
    asset_tracker: "APPL",
    symbol: "USD",
    settle_date: ~N[2023-10-04 14:30:00],
    quantity: 10,
    unit_price: Decimal.new("150.00")
  }

  {:ok, asset} = AssetTracker.UseCases.AddPurchaseUseCase.execute(attrs)
  """

  alias AssetTracker.Database
  alias AssetTracker.Entities.Asset

  @type attrs :: %{
          asset_tracker: String.t(),
          symbol: String.t(),
          settle_date: NaiveDateTime.t(),
          quantity: Integer.t(),
          unit_price: Decimal.t()
        }

  @spec execute(attrs()) :: {:ok, Asset.t()}
  def execute(attrs) do
    {:ok, asset} = Asset.build(attrs)

    Database.insert("assets", asset)

    {:ok, asset}
  end
end
