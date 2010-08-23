class TakeScreenshotStep < Step
  property :css, :string
  
  def run!(session, check_run)
    screenshot = session.take_screenshot(css)
    screenshot.step = self
    screenshot.check_run = check_run
    screenshot.save
  end
end
