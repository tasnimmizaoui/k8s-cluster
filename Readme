# Kubernetes Cluster Setup (kubeadm) — Summary

## Objective

Set up a Kubernetes cluster from scratch with:

* 1 Control Plane node
* 1 Worker node

---

## Environment

* OS: Ubuntu 22.04 (Vagrant VMs)
* Control Plane IP: 192.168.56.10
* Worker Node IP: 192.168.56.11
* Runtime: containerd
* Kubernetes version: v1.36
* Networking: Flannel CNI

---

## Step 1 — VM Preparation

On both nodes:

* Disabled swap:

  ```bash
  sudo swapoff -a
  ```

* Enabled required kernel modules:

  ```bash
  sudo modprobe br_netfilter
  ```

* Made it persistent:

  ```bash
  echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
  ```

* Configured sysctl:

  ```bash
  net.bridge.bridge-nf-call-iptables = 1
  net.bridge.bridge-nf-call-ip6tables = 1
  net.ipv4.ip_forward = 1
  ```

---

## Step 2 — Install containerd

Installed container runtime:

```bash
sudo apt install -y containerd
```

Generated configuration:

```bash
containerd config default | sudo tee /etc/containerd/config.toml
```

Configured systemd cgroup driver:

```toml
SystemdCgroup = true
```

Restarted service:

```bash
sudo systemctl restart containerd
```

---

## Step 3 — Install Kubernetes Components

Installed:

* kubeadm
* kubelet
* kubectl

Configured Kubernetes repository and installed packages:

```bash
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## Step 4 — Initialize Control Plane

Executed on control plane node:

```bash
sudo kubeadm init \
  --apiserver-advertise-address=192.168.56.10 \
  --pod-network-cidr=10.244.0.0/16
```

Configured kubectl:

```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
```

---

## Step 5 — Install Network Plugin

Deployed Flannel CNI:

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

---

## Step 6 — Join Worker Node

Used kubeadm join command generated during initialization:

```bash
kubeadm join <control-plane-ip>:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

---

## Step 7 — Verification

Checked cluster status:

```bash
kubectl get nodes
```

Result:

```
controlplane   Ready
worker         Ready
```

Checked system pods:

```bash
kubectl get pods -n kube-system
```

All pods running successfully.

---

## Issues Encountered & Fixes

### 1. containerd package fetch error

* Cause: outdated apt cache
* Fix: `sudo apt-get update`

---

### 2. Flannel crashing

* Cause: missing `br_netfilter` kernel module
* Fix:

  * loaded module
  * configured sysctl

---

### 3. kubectl not working on worker

* Cause: missing kubeconfig
* Fix: copied `admin.conf` manually

---

## Key Learnings

* Kubernetes depends heavily on Linux networking (iptables, bridges, kernel modules)
* containerd must be configured with systemd cgroups
* CNI plugins are mandatory for pod networking
* kubeadm simplifies cluster setup but requires correct system preparation

---

## Final Result

A fully functional Kubernetes cluster with:

* 1 control plane node
* 1 worker node
* working pod networking
* cluster in Ready state

---

## Next Steps (optional improvements)

* Deploy applications (e.g., Nginx)
* Expose services (NodePort / ClusterIP)
* Test inter-node pod communication
* Experiment with other CNIs (Calico, Cilium)
