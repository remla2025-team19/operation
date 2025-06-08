Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  num_workers = 2

  # Shared provisioning config (fix: pass extra_vars here too)
  config.vm.provision "ansible" do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "ansible/general.yml"
    ansible.extra_vars = {
      num_workers: num_workers
    }
  end

  # Controller
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "192.168.56.100"
    ctrl.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = 4096
    end
    ctrl.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "ansible/ctrl.yml"
      ansible.extra_vars = {
        num_workers: num_workers
      }
    end
  end

  # Workers
  (1..num_workers).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.cpus = 4
        vb.memory = 6144
      end
      node.vm.provision "ansible" do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "ansible/node.yml"
        ansible.extra_vars = {
          num_workers: num_workers
        }
      end
    end
  end
end
