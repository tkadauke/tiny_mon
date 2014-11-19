class CheckAllLinksStep < ScopableStep

  class ContentCheckFailed < CheckFailed; end

  def run!(session, check_run)
    session.log "Checking all links"
    currentUrl = session.driver.current_url
    with_optional_scope(session) do
      links = session.all('a', :visible => true)
      offset = 0
      links.each do |link|
        links = session.all('a', :visible => true)
        link = links[offset] if offset < links.count
        #can we handle this smarter?
        session.log 'clicking link ' + link.text.to_s
        link.click
        if session.driver.browser.window_handles.size > 1
          new_window = session.driver.browser.window_handles.last
          session.within_window new_window do
            #code
            check_status session.status_code
            session.log 'Visited (new window)' +  session.driver.current_url
            session.execute_script "window.close()"
          end

        else
          session.log 'Visited ' +  session.driver.current_url
          session.visit currentUrl
          check_status session.status_code
        end
          offset  = offset +1
      end
    end
  end

  def check_status status
    if status != 200
      session.fail ContentCheckFailed, "Expected link http status to be 200, but  got to not contain #{status}"
    end
  end
end
