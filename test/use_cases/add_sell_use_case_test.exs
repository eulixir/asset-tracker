defmodule AssetTrackerTest.AddSellUseCase do
  use ExUnit.Case

  alias AssetTracker.Entities.Asset
  alias AssetTracker.Database
  alias AssetTracker.UseCases.AddPurchaseUseCase
  alias AssetTracker.UseCases.AddSellUseCase

  describe "Test AddSellUseCase.execute/4" do
    test "It should be able to sell when the first operation_value asset is equal to sell asset" do
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

      assert {:ok, response} = AddSellUseCase.execute(params)

      assert response.profit == 0
      assert response.loss == 0
      assert response.assets == []
    end

    test "It should be able to sell when quantity is greather than first_asset and have profit in this operation" do
      Database.reset()

      asset = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(asset)

      selling_asset = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 2,
        unit_price: Decimal.new(6)
      }

      assert {:ok, response} = AddSellUseCase.execute(selling_asset)

      profit =
        selling_asset.unit_price
        |> Decimal.sub(asset.unit_price)
        |> Decimal.mult(2)

      new_asset_quantity = asset.quantity - selling_asset.quantity

      expect =
        %{
          assets: [
            %Asset{
              symbol: asset.symbol,
              asset_tracker: asset.asset_tracker,
              settle_date: asset.settle_date,
              unit_price: asset.unit_price,
              operation_value: Decimal.mult(asset.unit_price, new_asset_quantity),
              quantity: new_asset_quantity
            }
          ],
          operation_balance: %{profit: profit, loss: 0}
        }

      assert ^expect = response
    end

    test "It should be able to sell when quantity is lower than first_asset and have loss in this operation" do
      Database.reset()

      attrs = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      {:ok, asset} = AddPurchaseUseCase.execute(attrs)

      selling_asset = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 2,
        unit_price: Decimal.new(4)
      }

      assert {:ok, response} = AddSellUseCase.execute(selling_asset)

      profit =
        selling_asset.unit_price
        |> Decimal.sub(asset.unit_price)
        |> Decimal.mult(selling_asset.quantity)
        |> Decimal.mult(-1)

      new_asset_quantity = asset.quantity - selling_asset.quantity

      expect =
        %{
          assets: [
            %Asset{
              symbol: asset.symbol,
              asset_tracker: asset.asset_tracker,
              settle_date: asset.settle_date,
              unit_price: asset.unit_price,
              operation_value: Decimal.mult(asset.unit_price, new_asset_quantity),
              quantity: new_asset_quantity
            }
          ],
          operation_balance: %{profit: 0, loss: profit}
        }

      assert ^expect = response
    end

    test "It should not be able to sell when does not have balance do operate" do
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
        quantity: 4,
        unit_price: Decimal.new(-5)
      }

      assert {:error, msg} = AddSellUseCase.execute(params)
      assert msg == "Insufficient balance for this operation"
    end
  end
end
