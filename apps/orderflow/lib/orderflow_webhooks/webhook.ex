defmodule OrderflowWebhooks.Webhook do
  use Ecto.Schema
  import Ecto.Changeset

  schema "webhooks" do
    field :url, :string
    field :events, {:array, :string}
    field :active, :boolean, default: true
    field :secret, :string

    timestamps()
  end

  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:url, :events, :active, :secret])
    |> validate_required([:url, :events])
    |> validate_format(:url, ~r/^https?:\/\/.+/)
  end
end
