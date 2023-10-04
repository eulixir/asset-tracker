defmodule AssetTrackerTest.Services.HasAbleToSell do
  use ExUnit.Case

  alias AssetTracker.Database
  alias AssetTracker.Entities.Asset
  alias AssetTracker.UseCases.AddPurchaseUseCase
  alias AssetTracker.Services.HasAbleToSell

  describe "Test HasAbleToSell.execute/4" do
    test "It should be able to return ok when has able to sell assets" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      {:ok, asset} =
        Asset.build(%{
          asset_tracker: "AMZN",
          symbol: "USD",
          settle_date: NaiveDateTime.utc_now(),
          quantity: 3,
          unit_price: Decimal.new(5)
        })

      assert :ok = HasAbleToSell.run(asset)
    end

    test "It should not be able to return ok when has not be able to sell assets" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(params)

      {:ok, asset} =
        Asset.build(%{
          asset_tracker: "AMZN",
          symbol: "USD",
          settle_date: NaiveDateTime.utc_now(),
          quantity: 5,
          unit_price: Decimal.new(5)
        })

      assert {:error, "Insufficient assets for this operation"} = HasAbleToSell.run(asset)
    end

    test "It should not be able to return ok when asset does not exist" do
      Database.reset()

      {:ok, asset} =
        Asset.build(%{
          asset_tracker: "AMZN",
          symbol: "USD",
          settle_date: NaiveDateTime.utc_now(),
          quantity: 5,
          unit_price: Decimal.new(5)
        })

      assert {:error, "Asset not found"} = HasAbleToSell.run(asset)
    end

    test "It should not be able to return ok when quantity equals a zero" do
      Database.reset()

      params = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 0,
        unit_price: Decimal.new(5)
      }

      {:ok, asset} = Asset.build(params)

      assert {:error, "The least you can do is more than one"} = HasAbleToSell.run(asset)
    end
  end
end
