#!/bin/bash
set -e

echo "=== Initializing Kubernetes Node ==="

# Update system
apt-get update
apt-get upgrade -y

# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Load kernel modules
modprobe br_netfilter
echo "br_netfilter" | tee /etc/modules-load.d/k8s.conf

# Configure sysctl
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

# Install containerd
apt-get install -y containerd

# Generate containerd config
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Enable systemd cgroup driver
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
systemctl restart containerd
systemctl enable containerd

# Add Kubernetes APT repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

# Install Kubernetes components
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Enable kubelet
systemctl enable kubelet

echo "=== Node initialization complete ==="
