# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def auto_update(container)
    periodically_call_remote(:url => request.request_uri, :update => container, :method => 'get')
  end
end
