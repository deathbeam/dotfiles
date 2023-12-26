# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.vm.synced_folder "shared", "/vagrant_shared"
  config.vm.disk :disk, size: "100GB", primary: true
  config.vm.provision "shell", path: "bootstrap.sh"
end
