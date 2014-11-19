Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :js_errors => false, :timeout => 300)
  #this is quite a large timeout, maybe we should increase this only on a per site base, for sites far away
end
