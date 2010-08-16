class TakeScreenshotStep < Step
  def run!(session, check_run)
    checksum = session.take_screenshot
    check_run.screenshots.create(:checksum => checksum)
  end
end
