Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.ssh.insert_key = false
  num_workers = 2
  ctrl_cpus = 1
  ctrl_memory = 4096
  worker_cpus = 2
  worker_memory = 6144
  base_ip = "192.168.56."

  # Generate inventory file
  File.open("ansible/inventory.cfg", "w") do |f|
    f.write("[controllers]\n")
    f.write("ctrl ansible_host=#{base_ip}100\n\n")
    f.write("[workers]\n")
    (1..num_workers).each do |i|
      f.write("node-#{i} ansible_host=#{base_ip}#{100 + i}\n")
    end
    f.write("\n[all:vars]\n")
    f.write("ansible_user=vagrant\n")
    f.write("ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key\n")
    f.write("ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n")
  end

  # Shared provisioning config (fix: pass extra_vars here too)
  # config.vm.provision "ansible" do |ansible|
  #   ansible.compatibility_mode = "2.0"
  #   ansible.playbook = "ansible/general.yml"
  #   ansible.inventory_path = "ansible/inventory.cfg"
  #   ansible.extra_vars = {
  #     num_workers: num_workers
  #   }
  # end

  # Controller
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "192.168.56.100"
    ctrl.vm.provider "virtualbox" do |vb|
      vb.cpus = ctrl_cpus
      vb.memory = ctrl_memory
    end
    # ctrl.vm.provision "ansible" do |ansible|
    #   ansible.compatibility_mode = "2.0"
    #   ansible.playbook = "ansible/ctrl.yml"
    #   ansible.extra_vars = {
    #     num_workers: num_workers
    #   }
    # end
  end

  # Workers
  (1..num_workers).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.cpus = worker_cpus
        vb.memory = worker_memory
      end

      if i == num_workers
        node.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.playbook = "ansible/general.yml"
          ansible.inventory_path = "ansible/inventory.cfg"
          ansible.limit = "all"
          ansible.extra_vars = {
            num_workers: num_workers
          }
        end

        node.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.playbook = "ansible/ctrl.yml"
          ansible.inventory_path = "ansible/inventory.cfg"
          ansible.limit = "controllers"
          ansible.extra_vars = {
            num_workers: num_workers
          }
        end

        node.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.playbook = "ansible/node.yml"
          ansible.inventory_path = "ansible/inventory.cfg"
          ansible.limit = "workers"
          ansible.extra_vars = {
            num_workers: num_workers
          }
        end
      end
    end
  end
end
