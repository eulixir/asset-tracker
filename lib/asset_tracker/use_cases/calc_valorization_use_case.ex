defmodule AssetTracker.UseCases.CalcValorizationUseCase do
  alias AssetTracker.Database

  def execute(symbol, asset_name, unit_price) do
    assets = Database.lookup("assets")

    default_balance = {Decimal.new(0), Decimal.new(0)}

    assets
    |> Enum.reduce(default_balance, fn asset, {balance, corrected_wallet} ->
      case asset.symbol == symbol && asset.asset_tracker == asset_name do
        true ->
          updated_operation_value = Decimal.add(asset.operation_value, balance)

          corrected_wallet =
            unit_price
            |> Decimal.new()
            |> Decimal.mult(asset.quantity)
            |> Decimal.add(corrected_wallet)

          {updated_operation_value, corrected_wallet}

        false ->
          {balance, corrected_wallet}
      end
    end)
    |> calc_corrected_wallet()
  end

  defp calc_corrected_wallet({balance, corrected_wallet}) do
    balance = Decimal.sub(corrected_wallet, balance) |> IO.inspect()

    {:ok, balance}
  end
end
