NimbleCSV.define(Orderflow.Exports.CSV, separator: ",", escape: "\"")

defmodule Orderflow.Exports.CSVHelper do
  @moduledoc """
  Helper functions for CSV encoding.
  """
  def encode_to_string(rows) do
    rows
    |> Orderflow.Exports.CSV.dump_to_iodata()
    |> IO.iodata_to_binary()
  end
end
