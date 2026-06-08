defmodule Orderflow.MultiTenancy.Subdomain do
  @moduledoc """
  Multi-tenancy support via subdomains.
  Extracts tenant from request subdomain.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    tenant = extract_tenant(conn)
    assign(conn, :tenant, tenant)
  end

  defp extract_tenant(conn) do
    case get_req_header(conn, "host") do
      [host | _] ->
        case String.split(host, ".") do
          [tenant, "orderflow", "com" | _] -> tenant
          ["www", "orderflow", "com" | _] -> "default"
          _ -> "default"
        end

      _ ->
        "default"
    end
  end
end
