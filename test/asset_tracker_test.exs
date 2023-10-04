defmodule AssetTrackerTest do
  use ExUnit.Case

  alias AssetTracker.Database
  alias AssetTracker.UseCases.AddPurchaseUseCase

  describe "Test Asset Tracker delegate module" do
    test "It should be able to purchase a asset" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      assert {:ok, _} = AssetTracker.add_purchase(params)
    end

    test "It should be able to sell a asset" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(-5)
      }

      assert {:ok, _} = AssetTracker.add_sale(params)
    end

    test "It should be able to calc the valuation of an asset" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      assert {:ok, _} = AssetTracker.calc_valuation("USD", "AMZN", 6)
    end
  end
end
