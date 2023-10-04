defmodule AssetTrackerTest.UseCases.CalcValuationUseCase do
  use ExUnit.Case

  alias AssetTracker.UseCases.CalcValuationUseCase
  alias AssetTracker.Database
  alias AssetTracker.UseCases.AddPurchaseUseCase

  describe "Test Calcvaluation.execute/2" do
    test "It should be able to return the balance of assets and de percentage of gain or loss" do
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
        symbol: "BRL",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      assert {:ok, balance} = CalcValuationUseCase.execute("USD", "AMZN", 6)
      assert balance == Decimal.new(3)

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      assert {:ok, balance} = CalcValuationUseCase.execute("USD", "AMZN", 6)
      assert balance == Decimal.new(6)
    end

    test "It should not be able to return balance when asset not exist" do
      Database.reset()

      assert {:ok, balance} = CalcValuationUseCase.execute("BRL", "AMZN", 6)
      assert balance == Decimal.new(0)
    end
  end
end
