# xv6-riscv setup with docker
---
## Setting up Docker image with Riscv-tools:
__Step 1:__ Install Docker by referring to the following link: _https://docs.docker.com/engine/install/_

__Step 2:__ Pull _riscv-tools_ docker image.
```
docker pull svkv/riscv-tools:v1.0
```
__Step 3:__ Verifying docker image
```
docker run -it svkv/riscv-tools:v1.0
```
The above command results in a bash. The _/home/os-iitm_ is the home directory which houses the _install/_ directory where all the RiscV related tools and qemu binaries are located. Press Ctrl^D to exit from the docker container.

## Building xv6-riscv with Docker 
__Step 1:__ Clone _xv6-riscv_ repo into your host system.
```
git clone https://github.com/mit-pdos/xv6-riscv
```

__Step 2__: Running _xv6-riscv_ inside docker
```
# Following command on host system
docker run -it -v <path to xv6-riscv in your host system>:/home/os-iitm/xv6-riscv svkv/riscv-tools:v1.0
# Following commands inside docker container
cd xv6-riscv
make qemu
```
The -v flag enables shared volumes between host system and docker container. The _xv6-riscv_ cloned repo resides on the host system and is shared with the docker container. 

__Step 3__: Debugging  _xv6-riscv_ with _gdb_
```
# Following command on host system
docker run -it -v <path to xv6-riscv in your host system>:/home/os-iitm/xv6-riscv svkv/riscv-tools:v1.0
# Following commands inside docker container
cd xv6-riscv
make qemu-gdb
# Note the tcp port id in the last output line

# Following command on host system in another terminal tab
docker ps
# Note the container id for svkv/riscv-tools:v1.0 container
docker exec -it <container-id> bash
# Following command inside the replica docker container created
riscv64-unknown-elf-gdb xv6-riscv/kernel/kernel
target remote localhost:<tcp port id>
```

## Note:
1. The _xv6-riscv_ repo should be cloned to your host system and not inside the docker container.
2. The workflow is as follows: Use your host system to edit any xv6-riscv related source file. Share the _xv6-riscv_ repo/volume with the docker container for build/execution with riscv-tools present in the docker container.
3. Any files that you create within the docker container outside of the shared volume is non-persistent and gets deleted automatically when you exit from the container.
4. Any file that is created within the docker container inside of the shared volume is persistent. But you need superuser permissions to edit them from your host system. There are ways to circumvent this, which you can refer it online.