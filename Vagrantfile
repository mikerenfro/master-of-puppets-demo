require './ruby/puppet_deps'

Vagrant.configure("2") do |config|
  # general settings for all VMs
  config.vm.box = "bento/rockylinux-8"
  config.vm.provision "shell", path: "shell/provision.sh"
  # settings specific to the git VM
  config.vm.define "git" do |git|
    git.vm.hostname = "git"
    git.vm.network "private_network", ip: "10.234.24.2",
      netmask: "255.255.255.0"
    git.vm.provision "shell", inline: install_dep('h0tw1r3-gitea', '2.0.0')
    git.vm.provision "puppet", manifests_path: "puppet"
  end
  # settings specific to the puppet VM
  config.vm.define "puppet" do |puppet|
    puppet.vm.provider "virtualbox" do |vb|
      vb.cpus = "2"
      vb.memory = "4096"
    end
    puppet.vm.hostname = "puppet"
    puppet.vm.network "private_network", ip: "10.234.24.3",
      netmask: "255.255.255.0"
    puppet.vm.provision "shell", inline: install_dep('theforeman-puppet', '16.5.0')
    puppet.vm.provision "shell", inline: install_dep('puppet-archive', '6.1.2')
    puppet.vm.provision "shell", inline: install_dep('puppet-ssh_keygen', '5.0.2')
    puppet.vm.provision "shell", inline: install_dep('puppet-r10k', '10.3.0')
    puppet.vm.provision "shell", inline: install_dep('puppetlabs-sshkeys_core', '2.4.0')
    puppet.vm.provision "shell", inline: install_dep('npwalker-recursive_file_permissions', '0.6.2')
    puppet.vm.provision "puppet", manifests_path: "puppet"
  end
  config.vm.define "web" do |web|
    web.vm.hostname = "web"
    web.vm.network "private_network", ip: "10.234.24.4",
    netmask: "255.255.255.0"
  end
end