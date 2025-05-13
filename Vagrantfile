Vagrant.configure("2") do |config|
    nodes = {
      "ctrl"   => "192.168.56.100",
      "node-1" => "192.168.56.101",
      "node-2" => "192.168.56.102"
    }
  
    #define vm for each ip
    nodes.each do |name, ip|
      config.vm.define name do |node|
        node.vm.box = "bento/ubuntu-24.04"
        node.vm.hostname = name
        node.vm.network "private_network", ip: ip

        node.ssh.private_key_path = "/root/.vagrant-keys/ctrl_key" if name == "ctrl"
  
        node.vm.provider "virtualbox" do |vb|
          vb.memory = name == "ctrl" ? 4096 : 6144
          vb.cpus = name == "ctrl" ? 1 : 2
          vb.name = "#{name}-vm"
        end
  
        node.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.playbook = "playbooks/#{name}.yaml"
        end
      end
    end
  end
  