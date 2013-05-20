require 'vagrant-berkshelf'

ruby_version = File.read(".rvmrc")[/ruby-([^\s]+)/, 1]

Vagrant.configure("2") do |config|
  config.berkshelf.enabled = true

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :private_network, ip: "192.168.33.10"

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "apt"
    chef.add_recipe "build-essential"
    chef.add_recipe "git"
    chef.add_recipe "phantomjs"
    chef.add_recipe "rvm::user"
    chef.add_recipe "rvm::vagrant"
    chef.add_recipe "mysql::server"
    
    chef.json = {
      :rvm => {
        :version => '1.11.7',
        :branch => "none",
        :user_installs => [{
          :user => 'vagrant',
          :default_ruby => ruby_version,
          :rubies => [ ruby_version ],
        }]
      },
      :mysql => {
        :server_root_password => '',
        :server_debian_password => '',
        :server_repl_password => ''
      }
    }
  end
  
  config.vm.provision :shell, :inline => <<-end
    export HOME=/home/vagrant
    sudo -u vagrant bash --login -c '
      cd /vagrant
      bundle install
      rake db:create:all db:migrate
    '
  end
end
