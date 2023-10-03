defmodule AssetTrackerTest.UseCases.CalcValorizationUseCase do
  use ExUnit.Case

  alias AssetTracker.UseCases.CalcValorizationUseCase
  alias AssetTracker.Database
  alias AssetTracker.UseCases.AddPurchaseUseCase

  describe "Test CalcValorization.execute/2" do
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

      assert {:ok, balance} = CalcValorizationUseCase.execute("USD", "AMZN", 6)
      assert balance == Decimal.new(3)

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      assert {:ok, balance} = CalcValorizationUseCase.execute("USD", "AMZN", 6)
      assert balance == Decimal.new(6)
    end

    test "It should not be able to return balance when asset not exist" do
      Database.reset()

      assert {:ok, balance} = CalcValorizationUseCase.execute("BRL", "AMZN", 6)
      assert balance == Decimal.new(0)
    end
  end
end
