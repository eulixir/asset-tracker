defmodule AssetTracker.UseCases.AddSellUseCase do
  alias AssetTracker.Services.HasAbleToSell
  alias AssetTracker.Database
  alias AssetTracker.Entities.Asset

  @type attrs :: %{
          asset_tracker: String.t(),
          symbol: String.t(),
          settle_date: NaiveDateTime.t(),
          quantity: Integer.t(),
          unit_price: Decimal.t()
        }

  @spec execute(attrs()) :: {:ok, Map.t()}
  def execute(attrs) do
    with {:ok, asset} <- Asset.build(attrs),
         :ok <- HasAbleToSell.run(asset) do
      assets = Database.lookup("assets")

      value =
        assets
        |> Enum.at(0)
        |> Map.get(:operation_value)
        |> Decimal.mult(-1)

      case value === asset.operation_value do
        true ->
          [_ | updated_assets] = assets
          Database.overwrite("assets", updated_assets)

          {:ok,
           %{
             assets: updated_assets,
             loss: 0,
             gain: 0
           }}

        false ->
          sell_assets(assets, {asset, 0})
      end
    end
  end

  defp sell_assets([asset | _tl] = assets, {updated_to_sell_asset, balance}) do
    case Decimal.gt?(updated_to_sell_asset.quantity, asset.quantity) do
      true -> sell_many_orders(assets, updated_to_sell_asset, balance)
      false -> sell_one_order(assets, updated_to_sell_asset, balance)
    end
  end

  defp sell_many_orders([asset | assets], selling_asset, balance) do
    new_quantity = selling_asset.quantity - asset.quantity

    quantity_to_calc = selling_asset.quantity - new_quantity

    updated_selling_asset = put_in(selling_asset.quantity, new_quantity)

    updated_balance =
      calc_gain_or_loss(
        asset.unit_price,
        %{quantity: quantity_to_calc, unit_price: selling_asset.unit_price},
        balance
      )

    sell_assets(assets, {updated_selling_asset, updated_balance})
  end

  defp sell_one_order([asset | assets], to_sell_asset, balance) do
    quantity = asset.quantity - to_sell_asset.quantity
    updated_operation_value = Decimal.mult(quantity, asset.unit_price)

    updated_asset = %Asset{
      asset_tracker: asset.asset_tracker,
      quantity: quantity,
      symbol: asset.symbol,
      settle_date: asset.settle_date,
      unit_price: asset.unit_price,
      operation_value: updated_operation_value
    }

    updated_assets = [updated_asset | assets]

    Database.overwrite("assets", updated_assets)

    operation_balance = calc_gain_or_loss(asset.unit_price, to_sell_asset, balance)

    {:ok, %{assets: updated_assets, operation_balance: operation_balance}}
  end

  defp calc_gain_or_loss(asset_unit_price, to_sell_asset, balance) do
    to_sell_asset.unit_price
    |> Decimal.sub(asset_unit_price)
    |> Decimal.mult(to_sell_asset.quantity)
    |> Decimal.add(balance)
  end
end