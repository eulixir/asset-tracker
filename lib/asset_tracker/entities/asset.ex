defmodule AssetTracker.Entities.Asset do
  defstruct ~w(symbol asset_tracker unit_price settle_date operation_value quantity)a

  @type t() :: %__MODULE__{
          symbol: String.t(),
          asset_tracker: String.t(),
          unit_price: Decimal.t(),
          settle_date: NaiveDateTime.t(),
          operation_value: Decimal.t(),
          quantity: Integer.t()
        }

  @type build_attrs :: %{
          asset_tracker: String.t(),
          symbol: String.t(),
          settle_date: NaiveDateTime.t(),
          quantity: Integer.t(),
          unit_price: Decimal.t()
        }

  @spec build(build_attrs()) :: {:ok, Asset.t()}
  def build(attrs) do
    asset = %__MODULE__{
      symbol: attrs.symbol,
      asset_tracker: attrs.asset_tracker,
      unit_price: attrs.unit_price,
      settle_date: attrs.settle_date,
      quantity: attrs.quantity,
      operation_value: Decimal.mult(attrs.unit_price, attrs.quantity)
    }

    {:ok, asset}
  end
end
