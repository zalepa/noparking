module ApplicationHelper
  def app_name
    I18n.t("app.name")
  end

  # Wraps I18n.translate so every lookup automatically has `app_name`
  # available for interpolation. Lets copy reference %{app_name}
  # without every call site threading the value through.
  def t(key, **options)
    super(key, app_name: app_name, **options)
  end
end
