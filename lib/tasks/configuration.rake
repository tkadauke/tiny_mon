namespace :configuration do
  desc 'Apply deployment-specific configuration'
  task :apply do
    raise "No deployment given. Use DEPLOYMENT environment variable to specify one" unless ENV['DEPLOYMENT']
    
    deployment = ENV['DEPLOYMENT']
    if File.exist?("config/deployments/default/")
      system "cp config/deployments/default/* config"
    end
    if File.exist?("config/deployments/#{deployment}/")
      system "cp config/deployments/#{deployment}/* config"
    end
  end
end
