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

  @spec execute(attrs()) :: {:ok, Asset.t()}
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
             profit: 0
           }}

        false ->
          sell_assets(assets, {asset})
      end
    end
  end

  defp sell_assets(assets, {updated_to_sell_asset}) do
    [asset | _tl] = assets

    case Decimal.gt?(updated_to_sell_asset.quantity, asset.quantity) do
      true -> has_more_the_exist_asset()
      false -> has_minus_the_exist_asset(assets, updated_to_sell_asset)
    end
  end

  defp has_more_the_exist_asset() do
  end

  defp has_minus_the_exist_asset([asset | assets], to_sell_asset) do
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

    operation_balance = calc_profit_or_loss(asset.unit_price, to_sell_asset)

    {:ok, %{assets: updated_assets, operation_balance: operation_balance}}
  end

  defp calc_profit_or_loss(asset_unit_price, to_sell_asset) do
    operation_balance =
      asset_unit_price
      |> Decimal.sub(to_sell_asset.unit_price)
      |> Decimal.mult(to_sell_asset.quantity)

    case Decimal.gt?(operation_balance, -1) do
      true ->
        %{loss: operation_balance, profit: 0}

      false ->
        %{loss: 0, profit: Decimal.mult(operation_balance, -1)}
    end
  end
end
