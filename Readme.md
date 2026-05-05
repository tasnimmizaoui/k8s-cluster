# Automated Kubernetes Cluster with Vagrant + Provisioning Scripts

This setup automates the entire Kubernetes cluster initialization using Vagrant's provisioning system on Windows with VirtualBox.

## How It Works

1. **Vagrantfile** - Defines VM resources and calls provisioning scripts
2. **scripts/init-node.sh** - Common setup for both nodes (swap, kernel modules, containerd, kubeadm)
3. **scripts/init-controlplane.sh** - Control plane specific (kubeadm init, Flannel CNI)
4. **scripts/join-command.sh** - Generated during control plane init, used by worker node

## Automation Flow

```
vagrant up
├── Create VMs (2 nodes)
├── Run init-node.sh on both nodes
│   ├── Disable swap
│   ├── Load kernel modules
│   ├── Install containerd
│   └── Install kubeadm, kubelet, kubectl
├── Run init-controlplane.sh on control plane
│   ├── kubeadm init
│   ├── Configure kubectl
│   ├── Deploy Flannel CNI
│   └── Generate join-command.sh
└── Worker node joins cluster using join-command.sh
```

## Usage

### Start cluster (fully automated)

```bash
cd c:\Users\user\k8s-cluster
vagrant up
```

This will:
1. Create 2 Ubuntu VMs
2. Install all Kubernetes components
3. Initialize the cluster
4. Join the worker node automatically

### Access nodes

```bash
# SSH into control plane
vagrant ssh controlplane

# SSH into worker
vagrant ssh worker

# Inside VM, verify cluster
kubectl get nodes
kubectl get pods -n kube-system
```

### Destroy cluster

```bash
vagrant destroy -f
```

## Configuration

Edit `Vagrantfile` to customize:
- VM memory/CPU
- Network IPs (192.168.56.x)
- Provisioning scripts

Edit `scripts/init-node.sh` or `scripts/init-controlplane.sh` for:
- Kubernetes version
- Pod network CIDR
- Container runtime options

## Benefits vs Manual Setup

✅ **Reproducible** - Identical setup every time  
✅ **Documented** - Infrastructure as Code  
✅ **Fast** - 5-10 minutes fully automated  
✅ **Portable** - Works on any Windows machine with VirtualBox  
✅ **Scalable** - Easy to add more worker nodes  
✅ **Version-controlled** - Track all changes in Git  

## Troubleshooting

### Worker node fails to join

```bash
# Check if join command exists
ls -la join-command.sh

# Manually run join on worker
vagrant ssh worker
bash /vagrant/join-command.sh
```

### Flannel pods stuck

```bash
# Check logs on control plane
vagrant ssh controlplane
kubectl logs -n kube-flannel deployment/kube-flannel-ds
```

### Reset and restart

```bash
vagrant destroy -f
vagrant up
```

## Files

- `Vagrantfile` - VM and provisioning configuration
- `scripts/init-node.sh` - Node initialization
- `scripts/init-controlplane.sh` - Control plane setup
- `join-command.sh` - Generated at runtime (worker join token)

## Next Steps

After cluster is running:

```bash
# Test cluster
kubectl run test-pod --image=nginx
kubectl get pods

# Deploy applications
kubectl apply -f your-app.yaml

# Monitor
kubectl logs -f test-pod
kubectl describe pod test-pod
```

## Portfolio Value

This demonstrates:
- ✅ Infrastructure as Code (IaC)
- ✅ Kubernetes cluster setup expertise
- ✅ Linux system administration
- ✅ Container orchestration
- ✅ Automation and CI/CD thinking
- ✅ Version control for infrastructure
