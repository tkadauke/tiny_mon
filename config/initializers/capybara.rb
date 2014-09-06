Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :js_errors => false, :timeout => 60)
  #this is quite a large timeout, mazbe we should increas this only on a per site base, for sites far away
end
