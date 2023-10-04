defmodule AssetTrackerTest.Services.CalcBalance do
  use ExUnit.Case

  alias AssetTracker.Database
  alias AssetTracker.UseCases.AddPurchaseUseCase
  alias AssetTracker.Services.CalcBalance

  describe "Test CalcBalance.execute/4" do
    test "It should be able calc balance" do
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
        asset_tracker: "GOOGL",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      {:ok, balance} = CalcBalance.run("AMZN")

      assert balance == Decimal.new(15)
    end

    test "It should not be able to calc balance when asset name does not exist" do
      Database.reset()

      assert {:error, "Asset not found"} = CalcBalance.run("GOOGL")
    end
  end
end
