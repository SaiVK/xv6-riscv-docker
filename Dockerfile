FROM ubuntu:latest AS builder1
RUN apt-get -y update && apt-get install -y tzdata && apt-get install -y git curl make gcc g++ autoconf automake \
      autotools-dev libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev \
      gawk build-essential bison flex texinfo gperf libtool patchutils \
      bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev \
      libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev git python \
      && rm -rf /var/lib/apt/lists/*
WORKDIR /home/os-iitm
# Installing RiscV Toolchain
ENV RISCV /home/os-iitm/install/riscv
ENV PATH "$RISCV/bin:${PATH}"
RUN git clone -j 16 https://github.com/riscv/riscv-gnu-toolchain
WORKDIR riscv-gnu-toolchain
RUN git checkout 2021.04.23
WORKDIR build
RUN ../configure --prefix=$RISCV --with-cmodel=medany
RUN make -j4

# Installing Spike simulator
FROM ubuntu:latest AS builder2
WORKDIR /home/os-iitm
ENV RISCV /home/os-iitm/install/riscv
ENV PATH "$RISCV/bin:${PATH}"
RUN apt-get -y update && apt-get install -y tzdata && apt-get install  -y curl make gcc g++ autoconf automake \
      autotools-dev libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev \
      gawk build-essential bison flex texinfo gperf libtool patchutils \
      bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev cmake \
      libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev git python \
      && rm -rf /var/lib/apt/lists/*
COPY --from=builder1 /home/os-iitm/install /home/os-iitm/install
RUN git clone https://github.com/riscv/riscv-isa-sim.git
WORKDIR riscv-isa-sim
WORKDIR build
RUN ../configure --prefix=$RISCV && make -j4 && make install
# Installing riscv-pk proxy kernel
RUN git clone https://github.com/riscv/riscv-pk.git
WORKDIR riscv-pk
WORKDIR build
RUN ../configure --prefix=$RISCV --host=riscv64-unknown-elf && make -j4 && make install
# Installing qemu
WORKDIR /home/os-iitm
ENV QEMU /home/os-iitm/install/qemu
ENV PATH "$QEMU/bin:${PATH}"
RUN git clone https://github.com/qemu/qemu
WORKDIR qemu
RUN git checkout v4.0.0
RUN ./configure --target-list=riscv64-softmmu --prefix=$QEMU --disable-werror && make -j4 && make install

# Final image
FROM ubuntu:latest
WORKDIR /home/os-iitm
ENV RISCV /home/os-iitm/install/riscv
ENV PATH "$RISCV/bin:${PATH}"
RUN apt-get -y update && apt-get install -y tzdata && apt-get install -y autoconf automake autotools-dev curl \
      libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev \
      make gcc g++ autoconf automake \
      autotools-dev libmpc-dev libmpfr-dev libgmp-dev \
      gawk build-essential bison flex texinfo gperf libtool patchutils \
      bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev cmake \
      libglib2.0-dev libfdt-dev zlib1g-dev git python \
      libpixman-1-dev libusb-1.0-0-dev \
      && rm -rf /var/lib/apt/lists/*
COPY --from=builder2 /home/os-iitm/install /home/os-iitm/install
ENV QEMU /home/os-iitm/install/qemu
ENV PATH "$QEMU/bin:${PATH}"
WORKDIR /home/os-iitm