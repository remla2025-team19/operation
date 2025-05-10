# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "bento/ubuntu-24.04"
BOX_VERSION = "202502.21.0"

CONTROL_CPUS = 1
CONTROL_MEMORY = "4096"

NODES = 2
NODE_CPUS = 2
NODE_MEMORY = "6144"


Vagrant.configure("2") do |config|

  config.vm.box = BOX_IMAGE
  config.vm.box_version = BOX_VERSION

  # General Provisioning (e.g., setting up authorized keys)
  config.vm.provision :ansible do |a|
    a.compatibility_mode = "2.0"
    a.playbook = "playbooks/general.yml"
    a.extra_vars = {
      WORKER_NODES: NODES
    }
  end

  # Control Node
  config.vm.define "ctrl" do |control|
    control.vm.hostname = "ctrl"
    control.vm.network "private_network", ip: "192.168.56.100"

    control.vm.provider "virtualbox" do |vb|
      vb.name = "ctrl-vm"
      vb.memory = CONTROL_MEMORY
      vb.cpus = CONTROL_CPUS
    end

    control.vm.provision :ansible do |a|
      a.compatibility_mode = "2.0"
      a.playbook = "playbooks/ctrl.yml"
    end
  end

  # Worker Nodes
  (1..NODES).each do |i|
    worker_name = "node-#{i}"
    config.vm.define worker_name do |node|
      node.vm.hostname = worker_name
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "#{worker_name}-vm"
        vb.memory = NODE_MEMORY
        vb.cpus = NODE_CPUS
      end

      node.vm.provision :ansible do |a|
        a.compatibility_mode = "2.0"
        a.playbook = "playbooks/node.yml"
      end
    end
  end
end
