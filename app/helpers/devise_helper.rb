module DeviseHelper
  def devise_form url, html = {}, &content
    form_for(resource, :as => resource_name, :url => url, :html => html, &content)
  end

  def devise_error_messages!
    error_explanation resource if resource
  end
end
