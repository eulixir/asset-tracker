defmodule AssetTrackerTest.Services.CalcQuantity do
  use ExUnit.Case

  alias AssetTracker.Database
  alias AssetTracker.UseCases.AddPurchaseUseCase
  alias AssetTracker.Services.CalcQuantity

  describe "Test CalcQuantity.execute/4" do
    test "It should be able calc asset quantity" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)
      AddPurchaseUseCase.execute(params)
      AddPurchaseUseCase.execute(params)
      AddPurchaseUseCase.execute(params)

      quantity = CalcQuantity.run("AMZN")

      assert quantity == 12
    end

    test "It should not be able calc when asset name given does not exist" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      quantity = CalcQuantity.run("GOOGL")

      assert quantity == 0
    end
  end
end
