Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :js_errors => false, :timeout => 900)
  #this is quite a large timeout, maybe we should increase this only on a per site base, for sites far away
end
Capybara.default_wait_time = 30