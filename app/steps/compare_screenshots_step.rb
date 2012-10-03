class CompareScreenshotsStep < Step
  def run!(session, check_run)
    # can't compare if there is nothing to compare to
    return if check_run.first_in_deployment?
    
    comparison = session.compare_screenshots
    check_run.screenshot_comparisons << comparison
  end
end
