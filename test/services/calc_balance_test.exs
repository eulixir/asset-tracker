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

      balance = CalcBalance.run("AMZN")

      assert balance == Decimal.new(15)
    end

    test "It should not be able to calc balance when asset name does not exist" do
      Database.reset()

      balance = CalcBalance.run("GOOGL")

      assert balance == 0
    end
  end
end
