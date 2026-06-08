defmodule OrderflowWeb.Gettext do
  @moduledoc """
  Internationalization with Gettext.

  Provides i18n support for Spanish and English.
  """
  use Gettext.Backend, otp_app: :orderflow_web
end
