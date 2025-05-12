# -*- mode: ruby -*-

NUM_WORKERS = 2

BOX_IMAGE = "bento/ubuntu-24.04"
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = BOX_IMAGE
  config.vm.box_check_update = true

  # Define control nodes
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "192.168.56.100"
    ctrl.vm.provider "virtualbox"  do |vb|
      vb.memory = 4096
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    end
    ctrl.vm.synced_folder "./shared", "/vagrant/shared", create: true
  end

  
  # Define worker nodes
  (1..NUM_WORKERS).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      end
      node.vm.synced_folder "./shared", "/vagrant/shared", create: true
    end
  end

  
  # Provision general to all nodes
  config.vm.provision "ansible" do |a|
    a.playbook = "playbooks/general.yaml"
  end

  # Ansible playbook for controller node
  config.vm.provision "ansible" do |a|
    a.playbook = "playbooks/ctrl.yaml"
  end

  # Ansible playbook for worker nodes
  config.vm.provision "ansible" do |a|
    a.playbook = "playbooks/node.yaml"
  end
end
