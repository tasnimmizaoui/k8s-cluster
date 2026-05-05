Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/jammy64"

  # Common provisioning for all nodes
  config.vm.provision "shell", path: "scripts/init-node.sh"

  # Control Plane
  config.vm.define "controlplane" do |cp|
    cp.vm.hostname = "controlplane"
    cp.vm.network "private_network", ip: "192.168.56.10"

    cp.vm.provider "virtualbox" do |vb|
      vb.memory = 3072
      vb.cpus = 2
    end

    # Control plane specific provisioning
    cp.vm.provision "shell", path: "scripts/init-controlplane.sh", args: ["192.168.56.10", "10.244.0.0/16"]
  end

  # Worker Node
  config.vm.define "worker" do |worker|
    worker.vm.hostname = "worker"
    worker.vm.network "private_network", ip: "192.168.56.11"

    worker.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    # Worker node joins after control plane is ready
    worker.vm.provision "shell", inline: <<-SHELL
      # Wait for join token to be available
      until [ -f /vagrant/join-command.sh ]; do
        echo "Waiting for join command..."
        sleep 5
      done
      
      bash /vagrant/join-command.sh
    SHELL
  end

end