require './ruby/puppet_deps'

Vagrant.configure("2") do |config|
  # general settings for all VMs
  config.vm.box = "bento/rockylinux-8"
  config.vm.provision "shell", path: "shell/provision.sh"
  config.vm.provision "shell", inline: install_dep('h0tw1r3-gitea', '2.0.0')
  config.vm.provision "puppet", manifests_path: "puppet"
  # settings specific to the git VM
  config.vm.define "git" do |git|
    git.vm.hostname = "git"
    git.vm.network "private_network", ip: "10.234.24.2",
      netmask: "255.255.255.0"
  end
end