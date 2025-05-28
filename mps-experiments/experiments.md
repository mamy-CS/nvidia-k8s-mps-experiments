# MPS experiments on Kubernetes(Kind) cluster
Running deployments using [GPU Burn](https://github.com/wilicc/gpu-burn) on various experiments

1. Show normal gpu burn run - 9 replicas - only deploys 8 pods with 10GB usage:

```console
kubectl apply -f mps-custom-deployment-gpuburn.yaml
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

2. Show with ./gpu burn -m 70% 120 - 12 replicas - only deploys 8 pods with 7GB usage

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

3. Show with CUDA_MPS_PINNED_DEVICE_MEM_LIMIT=''0=6GB'' - 17 replicas - only deploys 8 pods with 6GB usage and both gpus are limited at 6GB

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

4. Show with CUDA_MPS_PINNED_DEVICE_MEM_LIMIT=''GPU-31cfe05c-ed13-cd17-d7aa-c63db5108c24=5GB,GPU-8d042338-e67f-9c48-92b4-5b55c7e5133c=10GB'' - 20 replicas
The memory limit set for both GPUs is bypassed, and GPUs are maxed out.

Errors seen in the pods:
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

5. Show with CUDA_VISIBLE_DEVICES=GPU-31cfe05c-ed13-cd17-d7aa-c63db5108c24 - chooses only gpu 0 
4 workloads are run only on gpu 0 at 10GB each

Errors seen in the pods:
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
