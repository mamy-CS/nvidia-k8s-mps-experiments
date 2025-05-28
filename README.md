# NVIDIA MPS in Kubernetes KIND cluster with the NVIDIA GPU Operator using the [NVIDIA device plugin for Kubernetes](https://github.com/NVIDIA/k8s-device-plugin/tree/v0.15.0)

This document outlines the feasibility, support, and risks of using [NVIDIA MPS (Multi-Process Service)](https://docs.nvidia.com/deploy/mps/)  on a Kubernetes (Kind) cluster. 

## Configure cluster for MPS

1. Create Kind cluster and install the NVIDIA GPU Operator:

```console
bash ./setup.sh
```

After successful installation and readiness of the GPU operator pods:

```console
NAME                                                         READY   STATUS      RESTARTS   AGE
gpu-feature-discovery-fphvk                                  1/1     Running     0          2m8s
gpu-operator-56977fc4b6-jsz45                                1/1     Running     0          3m32s
gpu-operator-node-feature-discovery-gc-78d798587d-mtnng      1/1     Running     0          3m32s
gpu-operator-node-feature-discovery-master-96db5444c-9fn4k   1/1     Running     0          3m32s
gpu-operator-node-feature-discovery-worker-kpxc5             1/1     Running     0          3m32s
nvidia-container-toolkit-daemonset-v5hqb                     1/1     Running     0          2m12s
nvidia-cuda-validator-kkvs2                                  0/1     Completed   0          34s
nvidia-dcgm-exporter-6zk88                                   1/1     Running     0          2m9s
nvidia-device-plugin-daemonset-t8bw6                         1/1     Running     0          2m10s
nvidia-operator-validator-k9hh9                              0/1     Init:3/4    0          2m11s
```
2. Configure containerd (for Kubernetes) [if not configured]:
Configure the container runtime by using the nvidia-ctk command:

```console
sudo nvidia-ctk runtime configure --runtime=containerd
```
Restart containerd:
```console
sudo systemctl restart containerd
```
3. Apply MPS config:
Configure the container runtime by using the nvidia-ctk command:

```console
kubectl create -n gpu-operator -f mps-config.yaml
```

Sample configuration: 
```console
version: v1
sharing:
  mps:
    renameByDefault: true
    resources:
    - name: nvidia.com/gpu
      replicas: 4
    ...
```
Patch the cluster policies:

```console
kubectl patch clusterpolicies.nvidia.com/cluster-policy \
    -n gpu-operator --type merge \
    -p '{"spec": {"devicePlugin": {"config": {"name": "mps-config", "default": "any"}}}}'
```

Watch for nvidia-device-plugin-mps-control-daemon pod to come up:

```console
kubectl get pods -n gpu-operator --watch
```

```console
NAME                                                         READY   STATUS      RESTARTS   AGE
gpu-feature-discovery-gk5ks                                  2/2     Running     0          2m19s
gpu-operator-56977fc4b6-jsz45                                1/1     Running     0          25h
gpu-operator-node-feature-discovery-gc-78d798587d-mtnng      1/1     Running     0          25h
gpu-operator-node-feature-discovery-master-96db5444c-9fn4k   1/1     Running     0          25h
gpu-operator-node-feature-discovery-worker-kpxc5             1/1     Running     0          25h
nvidia-container-toolkit-daemonset-v5hqb                     1/1     Running     0          25h
nvidia-cuda-validator-kkvs2                                  0/1     Completed   0          25h
nvidia-dcgm-exporter-6zk88                                   1/1     Running     0          25h
nvidia-device-plugin-daemonset-pf8js                         2/2     Running     0          2m20s
nvidia-device-plugin-mps-control-daemon-fjhq8                2/2     Running     0          86s
nvidia-operator-validator-k9hh9                              1/1     Running     0          25h
```

4. Check the node Capacity and Allocatable for GPU resources update:
Since renameByDefault=true, the resource will be advertised under the name <resource-name>.shared instead of simply <resource-name>.

```console
kubectl describe node kind-control-plane
```

In this case, this configuration was applied to a node with 2 GPUs, and the plugin advertises 8 nvidia.com/gpu.shared resources to Kubernetes instead of 2. And nvidia.com will show 0 to avoid confusion. 

```console
Capacity:
  nvidia.com/gpu:         0
  nvidia.com/gpu.shared:  8
Allocatable:
  nvidia.com/gpu:         0
  nvidia.com/gpu.shared:  8
```

