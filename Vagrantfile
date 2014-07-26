ruby_version = File.read("Gemfile")[/ruby '([^\s]+)'/, 1]
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

ENV['VAGRANT_DEFAULT_PROVIDER'] ||= 'docker'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.ssh.password = "vagrant"
  #config.vm.box = "mitchellh/boot2docker"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
    v.check_guest_additions = false
    v.functional_vboxsf = false
  end

  #config.vm.box = "ubuntu/trusty64"

  config.vm.define "redis" do |redis|
    redis.vm.provider "docker" do |d|
      d.name = "redis"
      d.build_dir = "vagrant/redis"
    end
  end

  config.vm.define "db" do |app|
    app.vm.provider "docker" do |d|
      d.image = "postgres"
      d.name = "db"
    end
  end
  config.vm.define "app" do |app|
    app.vm.provider "docker" do |d|
      d.build_dir = "."
      d.link "db:db"
      d.link "redis:redis"
      d.remains_running = true
      #d.has_ssh = true
    end
  end
end
