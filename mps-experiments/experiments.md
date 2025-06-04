# MPS experiments on Kubernetes(Kind) cluster
Running deployments using [GPU Burn](https://github.com/wilicc/gpu-burn) on various experiments

* NVIDIA's Multi-Process Service (MPS) was officially introduced in CUDA Toolkit version 5.5. But CUDA 11+ is ideal.
- Pre-CUDA 4.0 Applications: Not supported under CUDA MPS. 
- Pre-CUDA 11.5: Lack support for CUDA_MPS_PINNED_DEVICE_MEM_LIMIT, limiting fine-grained memory control.
- CUDA Version ≤ 9:
   - Legacy Ubuntu-based NVIDIA images (pre-2019):
      - Lack MPS daemon binaries.
      - Require manual /tmp/nvidia-mps handling and control script setup.
   - Images with outdated nvidia-smi:
      - May crash when MPS tries to initialize or allocate.
        
* These experiments are run using CUDA version 12.2
  
## Experiments
1. Normal GPU Burn Run - 9 Replicas, 10GB Usage Each

### Observation:
- Only 8 pods deployed
- ~10GB GPU memory usage per process

The 30 MiB used by nvidia-cuda-mps-server reflects the baseline memory overhead for:
* Loading CUDA driver components
* Allocating shared memory structures for MPS control
* Maintaining channels (e.g., control socket)
* Holding persistent state like scheduling queues and request buffers
This memory usage is independent of any client workload, and is typically small (20–50 MiB)
There is only one Global MPS Daemon (nvidia-cuda-mps-server):
    * The MPS control daemon manages all available GPUs.
    * There is no separate MPS server per GPU.
    * On the nvidia-smi commands below, you see the same nvidia-cuda-mps-server PID listed across both GPUs; it just means it opens contexts on each GPU as needed.
 
```console
kubectl apply -f mps-custom-deployment-gpuburn.yaml
```

```console
nvidia-smi
```

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   84C    P0            253W /  250W |   36386MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   83C    P0            244W /  250W |   36386MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    957485    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957490    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957501    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957520    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    958340    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958347    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958365    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958394    M+C   ./gpu_burn                                   9086MiB |
+-----------------------------------------------------------------------------------------+

```

2. GPU Burn with Memory Flag: -m 70% (12 Replicas)

### Observation:
- Only 8 pods were successfully deployed
- ~7GB GPU memory usage per process
  
```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   84C    P0            236W /  250W |   28194MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   85C    P0            182W /  250W |   28194MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    964354    M+C   ./gpu_burn                                   7038MiB |
|    0   N/A  N/A    964355    M+C   ./gpu_burn                                   7038MiB |
|    0   N/A  N/A    964356    M+C   ./gpu_burn                                   7038MiB |
|    0   N/A  N/A    964377    M+C   ./gpu_burn                                   7038MiB |
|    1   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    964348    M+C   ./gpu_burn                                   7038MiB |
|    1   N/A  N/A    964351    M+C   ./gpu_burn                                   7038MiB |
|    1   N/A  N/A    964380    M+C   ./gpu_burn                                   7038MiB |
|    1   N/A  N/A    964383    M+C   ./gpu_burn                                   7038MiB |
+-----------------------------------------------------------------------------------------+
```

3. CUDA_MPS_PINNED_DEVICE_MEM_LIMIT='0=6GB' (17 Replicas)
* Note: CUDA_MPS_PINNED_DEVICE_MEM_LIMIT is only valid starting in version CUDA 11.5. Images built with earlier CUDA versions don't support the CUDA_MPS_PINNED_DEVICE_MEM_LIMIT variable.
  
### Observation:
- 8 pods deployed
- Memory limit respected, 6GB per workload but applied on both GPUs instead of just gpu 0
  
```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   84C    P0            251W /  250W |   22050MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   84C    P0            149W /  250W |   22050MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    970456    M+C   ./gpu_burn                                   5502MiB |
|    0   N/A  N/A    970461    M+C   ./gpu_burn                                   5502MiB |
|    0   N/A  N/A    970465    M+C   ./gpu_burn                                   5502MiB |
|    0   N/A  N/A    970468    M+C   ./gpu_burn                                   5502MiB |
|    1   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    970173    M+C   ./gpu_burn                                   5502MiB |
|    1   N/A  N/A    970445    M+C   ./gpu_burn                                   5502MiB |
|    1   N/A  N/A    970453    M+C   ./gpu_burn                                   5502MiB |
|    1   N/A  N/A    970474    M+C   ./gpu_burn                                   5502MiB |
+-----------------------------------------------------------------------------------------+
```

4. GPU-specific Memory Limits (20 replicas)
### ENV:
```console
CUDA_MPS_PINNED_DEVICE_MEM_LIMIT=''GPU-31cfe05c-ed13-cd17-d7aa-c63db5108c24=5GB,GPU-8d042338-e67f-9c48-92b4-5b55c7e5133c=10GB''
```
### Observation:
- Limits not respected (The memory limit set for both GPUs is bypassed)
- Memory usage maxed out

### Errors seen in the pods:
Couldn't init a GPU test: Error (gpu_burn-drv.cpp:113): MPS server is not ready to accept new MPS client requests
Couldn't init CUDA: Error (gpu_burn-drv.cpp:304): MPS server is not ready to accept new MPS client requests
No CUDA devices
No clients are alive!  Aborting
gpu-burn Burning for 120 seconds.
gpu-burn Couldn't init a GPU test: Error (gpu_burn-drv.cpp:113): unspecified launch failure

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   84C    P0            146W /  250W |   39717MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   84C    P0            119W /  250W |   39717MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    974872    M+C   ./gpu_burn                                  36222MiB |
|    0   N/A  N/A    974992    M+C   ./gpu_burn                                   3454MiB |
|    1   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    974993    M+C   ./gpu_burn                                  35966MiB |
|    1   N/A  N/A    974996    M+C   ./gpu_burn                                   3710MiB |
+-----------------------------------------------------------------------------------------+
```

5. Specify which GPU’s should be visible to the CUDA application [GPU 0]
### ENV:
```console
CUDA_VISIBLE_DEVICES=GPU-31cfe05c-ed13-cd17-d7aa-c63db5108c24
```
### Observation:
- 4 workloads are run only on gpu 0 at 10GB each
- GPU 1 remains idle

### Errors seen in the pods:
terminate called after throwing an instance of 'std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >'
No clients are alive!  Aborting
Couldn't init a GPU test: Error (gpu_burn-drv.cpp:113): unspecified launch failure
Couldn't init CUDA: Error (gpu_burn-drv.cpp:304): an illegal memory access was encountered
Couldn't init a GPU test: Error (gpu_burn-drv.cpp:112): initialization error

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   82C    P0            255W /  250W |   36386MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   75C    P0             47W /  250W |      39MiB /  40960MiB |      0%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    986485    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    986572    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    986588    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    986615    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
+-----------------------------------------------------------------------------------------+
```

6. Specify CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
### ENV:
```console
CUDA_MPS_ACTIVE_THREAD_PERCENTAGE="25"
```
   - This does not cap memory, only execution unit (SM) usage.
   - This [comment](https://github.com/NVIDIA/nvidia-docker/issues/807#issuecomment-411634931) is helpful
### Observation:
- No change in sm usage seen on both GPUs

```console
nvidia-smi dmon -s u

# gpu     sm    mem    enc    dec    jpg    ofa 
# Idx      %      %      %      %      %      % 
    0    100     21      0      0      0      0 
    1    100     22      0      0      0      0 
    0    100     19      0      0      0      0 
    1    100     19      0      0      0      0 
    0    100     19      0      0      0      0 
    1    100     25      0      0      0      0 
    0    100     19      0      0      0      0 
    1    100     22      0      0      0      0 
    0    100     25      0      0      0      0 
    1    100     21      0      0      0      0 
    0    100     26      0      0      0      0 
    1    100     26      0      0      0      0 
    0    100     19      0      0      0      0 
    1    100     23      0      0      0      0 
    0    100     19      0      0      0      0 
    1    100     23      0      0      0      0 
    0    100     26      0      0      0      0 
    1    100     24      0      0      0      0 
```
7. Updating the mps config replica while workloads are running with a previous config (9 replicas)
* Initial mps config:
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

```console
Capacity:
  nvidia.com/gpu:         0
  nvidia.com/gpu.shared:  8
Allocatable:
  nvidia.com/gpu:         0
  nvidia.com/gpu.shared:  8
```
Requesting 9 workloads to run, each with 10GB of memory:
### Observation:
- Only 8 pods deployed
- ~10GB GPU memory usage per process

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   84C    P0            253W /  250W |   36386MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   83C    P0            244W /  250W |   36386MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    957485    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957490    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957501    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957520    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    958340    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958347    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958365    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958394    M+C   ./gpu_burn                                   9086MiB |
+-----------------------------------------------------------------------------------------+

```
* Updated config (increased replica to 10):
```console
version: v1
sharing:
  mps:
    renameByDefault: true
    resources:
    - name: nvidia.com/gpu
      replicas: 10
    ...
```

```console
Capacity:
  nvidia.com/gpu:         0
  nvidia.com/gpu.shared:  20
Allocatable:
  nvidia.com/gpu:         0
  nvidia.com/gpu.shared:  20
```
### Observation:
- 8 pods continue running with ~10GB memory
- The remaining pod gets deplpoyed and allocated ~4GB memory
```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   80C    P0            138W /  250W |   39792MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   67C    P0             45W /  250W |   36393MiB /  40960MiB |      0%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    316555    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    316569    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    316593    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    316619    M+C   ./gpu_burn                                   9088MiB |
|    0   N/A  N/A    321604    M+C   ./gpu_burn                                   3398MiB |
|    0   N/A  N/A    321606      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    316565    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    316599    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    316611    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    316618    M+C   ./gpu_burn                                   9088MiB |
|    1   N/A  N/A    321606      C   nvidia-cuda-mps-server                         30MiB |
+-----------------------------------------------------------------------------------------+
```

8. Setting active thread percentage and mps pinned device mem limit using env variables together (9 replicas)
### ENV
```console
env:
   - name: CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
      value: "20"
   - name: CUDA_MPS_PINNED_DEVICE_MEM_LIMIT
      value: "0=8000M"
```

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   72C    P0            248W /  250W |   28114MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   78C    P0            246W /  250W |   28114MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    281328      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    281524    M+C   ./gpu_burn                                   7018MiB |
|    0   N/A  N/A    281675    M+C   ./gpu_burn                                   7018MiB |
|    0   N/A  N/A    282212    M+C   ./gpu_burn                                   7018MiB |
|    0   N/A  N/A    282387    M+C   ./gpu_burn                                   7018MiB |
|    1   N/A  N/A    281326    M+C   ./gpu_burn                                   7018MiB |
|    1   N/A  N/A    281328      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    281848    M+C   ./gpu_burn                                   7018MiB |
|    1   N/A  N/A    282039    M+C   ./gpu_burn                                   7018MiB |
|    1   N/A  N/A    282565    M+C   ./gpu_burn                                   7018MiB |
+-----------------------------------------------------------------------------------------+
```

```console
nvidia-smi dmon -s u
# gpu     sm    mem    enc    dec    jpg    ofa 
# Idx      %      %      %      %      %      % 
    0    100     18      0      0      0      0 
    1    100     23      0      0      0      0 
    0    100     17      0      0      0      0 
    1    100     15      0      0      0      0 
    0    100     16      0      0      0      0 
    1    100     15      0      0      0      0 
    0    100     19      0      0      0      0 
    1    100     17      0      0      0      0 
    0    100     16      0      0      0      0 
    1    100     15      0      0      0      0 
    0    100     16      0      0      0      0 
    1    100     18      0      0      0      0 
    0    100     20      0      0      0      0 
    1    100     15      0      0      0      0 
    0    100     17      0      0      0      0 
```
### Observation:
- 8 pods deployed
- Memory limit respected, 8GB per workload, but applied on both GPUs instead of just gpu 0
- No change in sm usage seen on both GPUs
  
9. Setting mps pinned device mem limit using gpu id (9 replicas)
### ENV
```console
env:
   - name: CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
      value: "20"
   - name: CUDA_MPS_PINNED_DEVICE_MEM_LIMIT
      value: "GPU-31cfe05c-ed13-cd17-d7aa-c63db5108c24=8000M"
```

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   84C    P0            139W /  250W |   28114MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   84C    P0            111W /  250W |   39677MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    281328      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    292742    M+C   ./gpu_burn                                   7018MiB |
|    0   N/A  N/A    292931    M+C   ./gpu_burn                                   7018MiB |
|    0   N/A  N/A    292932    M+C   ./gpu_burn                                   7018MiB |
|    0   N/A  N/A    292943    M+C   ./gpu_burn                                   7018MiB |
|    1   N/A  N/A    281328      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    291768    M+C   ./gpu_burn                                  36202MiB |
|    1   N/A  N/A    292745    M+C   ./gpu_burn                                   3434MiB |
+-----------------------------------------------------------------------------------------+
```
### Observation:
- 6 pods deployed
- Memory limit respected for GPU 0, 8GB per workload, 4 deployed on GPU 0
- but memory limit not respected for gpu 1, 2 pods deployed 1 with ~37GB and one with ~4GB
- No change in sm usage seen on both GPUs

10. Crashing one pod

* Initially 8 pods running in 2 gpus
```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   84C    P0            253W /  250W |   36386MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   83C    P0            244W /  250W |   36386MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    957485    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957490    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957501    M+C   ./gpu_burn                                   9086MiB |
|    0   N/A  N/A    957520    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    948322      C   nvidia-cuda-mps-server                         30MiB |
|    1   N/A  N/A    958340    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958347    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958365    M+C   ./gpu_burn                                   9086MiB |
|    1   N/A  N/A    958394    M+C   ./gpu_burn                                   9086MiB |
+-----------------------------------------------------------------------------------------+
```

* Crash one of the pods

```console
kubectl exec mps-deployment-gpuburn-857769f4c6-f2n9j -- pkill -SIGSEGV gpu_burn
kubectl get pods --watch
NAME                                      READY   STATUS             RESTARTS      AGE
mps-deployment-gpuburn-857769f4c6-4fw7b   1/1     Running            1 (11m ago)   11m
mps-deployment-gpuburn-857769f4c6-54zxw   1/1     Running            1 (11m ago)   11m
mps-deployment-gpuburn-857769f4c6-8mjkn   1/1     Running            1 (11m ago)   11m
mps-deployment-gpuburn-857769f4c6-bzg7r   0/1     Pending            0             11m
mps-deployment-gpuburn-857769f4c6-f2n9j   1/1     Running            1 (11m ago)   11m
mps-deployment-gpuburn-857769f4c6-hstj5   1/1     Running            0             11m
mps-deployment-gpuburn-857769f4c6-rx55x   0/1     CrashLoopBackOff   7 (44s ago)   11m
mps-deployment-gpuburn-857769f4c6-vqml9   1/1     Running            1 (11m ago)   11m
mps-deployment-gpuburn-857769f4c6-x2hvt   0/1     CrashLoopBackOff   7 (25s ago)   11m
mps-deployment-gpuburn-857769f4c6-8mjkn   0/1     Error              1 (12m ago)   12m
mps-deployment-gpuburn-857769f4c6-54zxw   0/1     Error              1 (12m ago)   12m
mps-deployment-gpuburn-857769f4c6-vqml9   0/1     Error              1 (12m ago)   12m
mps-deployment-gpuburn-857769f4c6-hstj5   0/1     Error              0             12m
mps-deployment-gpuburn-857769f4c6-f2n9j   0/1     Error              1 (12m ago)   12m
mps-deployment-gpuburn-857769f4c6-4fw7b   0/1     Error              1 (12m ago)   12m
mps-deployment-gpuburn-857769f4c6-hstj5   0/1     Error              1 (10s ago)   12m
mps-deployment-gpuburn-857769f4c6-54zxw   0/1     Error              2 (10s ago)   12m
mps-deployment-gpuburn-857769f4c6-vqml9   0/1     Error              2 (9s ago)    12m
mps-deployment-gpuburn-857769f4c6-f2n9j   0/1     Error              2 (9s ago)    12m
mps-deployment-gpuburn-857769f4c6-8mjkn   0/1     Error              2 (10s ago)   12m
mps-deployment-gpuburn-857769f4c6-4fw7b   0/1     Error              2 (10s ago)   12m
mps-deployment-gpuburn-857769f4c6-8mjkn   0/1     CrashLoopBackOff   2 (12s ago)   12m
mps-deployment-gpuburn-857769f4c6-hstj5   0/1     CrashLoopBackOff   1 (13s ago)   12m
mps-deployment-gpuburn-857769f4c6-vqml9   0/1     CrashLoopBackOff   2 (16s ago)   12m
mps-deployment-gpuburn-857769f4c6-4fw7b   0/1     CrashLoopBackOff   2 (14s ago)   12m
mps-deployment-gpuburn-857769f4c6-54zxw   0/1     CrashLoopBackOff   2 (15s ago)   12m
mps-deployment-gpuburn-857769f4c6-f2n9j   0/1     CrashLoopBackOff   2 (17s ago)   12m
```
```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.08             Driver Version: 550.127.08     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          Off |   00000000:0E:00.0 Off |                    0 |
| N/A   75C    P0             53W /  250W |       4MiB /  40960MiB |      0%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A100-PCIE-40GB          Off |   00000000:0F:00.0 Off |                    0 |
| N/A   77C    P0             47W /  250W |       4MiB /  40960MiB |      0%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

### Observation:
- All pods crash as well
- MPS is not isolated — shared GPU context lost
  
## Summary

- MPS limits are mostly respected when defined simply (e.g. 0=6GB).
- Complex syntax with UUIDs seems unreliable.
- Workload rejection/errors occur when attempting to overcommit memory.
- CUDA_VISIBLE_DEVICES helps to bind workloads, but may require careful tuning.
