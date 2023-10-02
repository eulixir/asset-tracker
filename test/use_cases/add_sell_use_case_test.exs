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
          operation_balance: profit
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

      loss =
        selling_asset.unit_price
        |> Decimal.sub(asset.unit_price)
        |> Decimal.mult(selling_asset.quantity)

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
          operation_balance: loss
        }

      assert ^expect = response
    end

    test "It should be able to sell many orders and loss profit in this operation" do
      Database.reset()

      attrs = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(attrs)

      {:ok, asset} = AddPurchaseUseCase.execute(attrs)

      selling_asset = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 4,
        unit_price: Decimal.new(4)
      }

      {quantity, balance} = call_profit(selling_asset)

      assert {:ok, response} = AddSellUseCase.execute(selling_asset)

      assert "assets" |> Database.lookup() |> length() == 1

      expect =
        %{
          assets: [
            %Asset{
              symbol: asset.symbol,
              asset_tracker: asset.asset_tracker,
              settle_date: asset.settle_date,
              unit_price: asset.unit_price,
              quantity: quantity,
              operation_value: Decimal.mult(asset.unit_price, quantity)
            }
          ],
          operation_balance: balance
        }

      assert ^expect = response
    end

    test "It should be able to sell many orders and have profit in this operation" do
      Database.reset()

      attrs = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 3,
        unit_price: Decimal.new(5)
      }

      AddPurchaseUseCase.execute(attrs)

      {:ok, asset} = AddPurchaseUseCase.execute(attrs)

      selling_asset = %{
        asset_tracker: "AMZN",
        symbol: "USD",
        settle_date: NaiveDateTime.utc_now(),
        quantity: 4,
        unit_price: Decimal.new(19)
      }

      {quantity, balance} = call_profit(selling_asset)

      assert {:ok, response} = AddSellUseCase.execute(selling_asset)

      assert "assets" |> Database.lookup() |> length() == 1

      expect =
        %{
          assets: [
            %Asset{
              symbol: asset.symbol,
              asset_tracker: asset.asset_tracker,
              settle_date: asset.settle_date,
              unit_price: asset.unit_price,
              quantity: quantity,
              operation_value: Decimal.mult(asset.unit_price, quantity)
            }
          ],
          operation_balance: balance
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
      assert msg == "Insufficient assets for this operation"
    end
  end

  defp call_profit(selling_asset) do
    "assets"
    |> Database.lookup()
    |> Enum.reduce({selling_asset.quantity, 0}, fn asset, {updated_asset_quantity, balance} ->
      case asset.quantity < updated_asset_quantity do
        true ->
          asset_quantity = updated_asset_quantity - asset.quantity

          result = Decimal.mult(selling_asset.unit_price, asset.quantity)

          operation_per_quantity = Decimal.mult(asset.unit_price, asset.quantity)

          total = Decimal.sub(result, operation_per_quantity)

          balance = Decimal.add(balance, total)

          {asset_quantity, balance}

        false ->
          result = Decimal.mult(selling_asset.unit_price, updated_asset_quantity)

          operation_per_quantity = Decimal.mult(asset.unit_price, updated_asset_quantity)

          new_asset_quantity = asset.quantity - updated_asset_quantity

          total = Decimal.sub(result, operation_per_quantity)

          balance = Decimal.add(balance, total)

          {new_asset_quantity, balance}
      end
    end)
  end
end
