FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

RUN apt-get update && \
    apt-get install -y git build-essential && \
    git clone https://github.com/wilicc/gpu-burn.git && \
    cd gpu-burn && make

WORKDIR /gpu-burn
ENTRYPOINT ["./gpu_burn"]
