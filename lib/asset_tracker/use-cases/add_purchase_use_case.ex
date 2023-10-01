defmodule AssetTracker.UseCases.AddPurchaseUseCase do
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
    {:ok, asset} = Asset.build(attrs)

    Database.insert("assets", asset)

    {:ok, asset}
  end
end
