#!/bin/bash
set -e

CONTROL_PLANE_IP=$1
POD_NETWORK_CIDR=$2

echo "=== Initializing Kubernetes Control Plane ==="
echo "Control Plane IP: $CONTROL_PLANE_IP"
echo "Pod Network CIDR: $POD_NETWORK_CIDR"

# Initialize control plane
kubeadm init \
  --apiserver-advertise-address=$CONTROL_PLANE_IP \
  --pod-network-cidr=$POD_NETWORK_CIDR \
  --cri-socket=unix:///run/containerd/containerd.sock

# Configure kubectl for root
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Configure kubectl for vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Deploy Flannel CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Wait for flannel to be ready
echo "Waiting for Flannel to be ready..."
kubectl rollout status daemonset/kube-flannel-ds -n kube-flannel --timeout=5m || true

# Generate and save join token for workers
echo "=== Generating worker join token ==="
kubeadm token create --print-join-command > /vagrant/join-command.sh
chmod +x /vagrant/join-command.sh

echo "=== Control Plane initialization complete ==="
echo "Cluster status:"
kubectl get nodes
kubectl get pods -n kube-system
