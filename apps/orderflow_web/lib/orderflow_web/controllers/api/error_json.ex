defmodule OrderflowWeb.Api.ErrorJSON do
  def render("error.json", %{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    %{error: %{code: "validation_error", message: "Invalid data", details: errors}}
  end

  def render("error.json", %{message: message}) do
    %{error: %{code: "error", message: message}}
  end

  def render("404.json", _assigns) do
    %{error: %{code: "not_found", message: "Resource not found"}}
  end

  def render("401.json", _assigns) do
    %{error: %{code: "unauthorized", message: "Authentication required"}}
  end

  def render("403.json", _assigns) do
    %{error: %{code: "forbidden", message: "Permission denied"}}
  end

  def render(template, _assigns) do
    %{
      error: %{
        code: "internal_error",
        message: Phoenix.Controller.status_message_from_template(template)
      }
    }
  end
end
