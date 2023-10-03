defmodule AssetTrackerTest.UseCase.AddPurchaseUseCase do
  use ExUnit.Case

  alias AssetTracker.Database
  alias AssetTracker.UseCases.AddPurchaseUseCase

  describe "Test AddPurchaseUseCase.execute/4" do
    test "It should be able to insert a new asset_tracker" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      {:ok, asset} = AddPurchaseUseCase.execute(params)

      %{asset_tracker: asset_tracker, operation_value: operation_value} = asset

      assert asset_tracker === params.asset_tracker
      assert operation_value === Decimal.new(15)

      assets = Database.lookup("assets")

      assert length(assets) === 1
    end
  end
end
