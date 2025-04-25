# Stage 1: Base system with NVIDIA dependencies and build OpenCV
FROM docker.io/arm64v8/ubuntu:22.04 as build

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

ARG DEBIAN_FRONTEND=noninteractive

# NVIDIA repositories setup - installing gnupg first
RUN apt-get update && apt-get install -y --no-install-recommends wget gnupg2 ca-certificates && \
    echo "deb https://repo.download.nvidia.com/jetson/common r35.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    echo "deb https://repo.download.nvidia.com/jetson/t234 r35.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    wget -O /etc/jetson-ota-public.key https://gitlab.com/nvidia/container-images/l4t-base/-/raw/master/jetson-ota-public.key && \
    apt-key add /etc/jetson-ota-public.key

# Install OpenCV build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    ccache \
    cmake \
    git \
    gcc-9 \
    g++-9 \
    libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev \
    libpng-dev libtiff-dev libglew-dev \
    libavcodec-dev libavformat-dev libswscale-dev \
    libgtk2.0-dev libgtk-3-dev \
    python3-pip \
    python3-dev \
    python3-numpy \
    libxvidcore-dev libx264-dev \
    libtbb-dev \
    libv4l-dev v4l-utils \
    libtesseract-dev libpostproc-dev \
    libvorbis-dev \
    libfaac-dev libmp3lame-dev libtheora-dev \
    libopencore-amrnb-dev libopencore-amrwb-dev \
    libopenblas-dev libatlas-base-dev libblas-dev \
    liblapack-dev liblapacke-dev libeigen3-dev gfortran \
    libhdf5-dev libprotobuf-dev protobuf-compiler \
    libgoogle-glog-dev libgflags-dev \
    cuda \
    libcudnn8 \
    libcudnn8-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set compiler environment variables
ENV CC=/usr/bin/gcc-9
ENV CXX=/usr/bin/g++-9
RUN ln -s /usr/bin/gcc-9 /usr/local/cuda/bin/gcc && \
    ln -s /usr/bin/g++-9 /usr/local/cuda/bin/g++

WORKDIR /project
ENV ARCH=53
ENV PTX="53"
ENV NO_JOB=4

# Clone, build and install OpenCV
RUN git clone --depth=1 https://github.com/opencv/opencv.git && \
    git clone --depth=1 https://github.com/opencv/opencv_contrib.git && \
    cd opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -D CMAKE_C_COMPILER_LAUNCHER=ccache \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D BUILD_opencv_java=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_DOCS=OFF \
    -D BUILD_ANDROID_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
    -D WITH_OPENCL=OFF \
    -D WITH_OPENEXR=OFF \
    -D BUILD_OPENEXR=OFF \
    -D CUDA_ARCH_BIN=${ARCH} \
    -D CUDA_ARCH_PTX=${PTX} \
    -D WITH_CUDA=ON \
    -D WITH_CUDNN=ON \
    -D WITH_CUBLAS=ON \
    -D ENABLE_FAST_MATH=ON \
    -D CUDA_FAST_MATH=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D ENABLE_NEON=ON \
    -D WITH_QT=OFF \
    -D WITH_OPENMP=ON \
    -D BUILD_TIFF=ON \
    -D WITH_FFMPEG=ON \
    -D WITH_GSTREAMER=ON \
    -D WITH_TBB=ON \
    -D BUILD_TBB=ON \
    -D BUILD_TESTS=OFF \
    -D WITH_EIGEN=ON \
    -D WITH_V4L=ON \
    -D WITH_LIBV4L=ON \
    -D WITH_PROTOBUF=ON \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_opencv_python3=ON \
    -D OPENCV_GENERATE_PYTHON_PACKAGE=ON \
    -D PYTHON_EXECUTABLE=/usr/bin/python3 \
    -D PYTHON_INCLUDE_DIR=/usr/include/python3.10 \
    -D PYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/libpython3.10.so \
    -D PYTHON_NUMPY_INCLUDE_DIR=/usr/lib/python3/dist-packages/numpy/core/include/ \
    -D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D BUILD_EXAMPLES=OFF \
    -D CMAKE_C_COMPILER=/usr/bin/gcc-9 \
    -D CMAKE_CXX_COMPILER=/usr/bin/g++-9 \
    -D CUDA_HOST_COMPILER=/usr/bin/gcc-9 \
    -D CMAKE_CXX_STANDARD=11 \
    -D CMAKE_CXX_FLAGS="-march=native -mtune=native" \
    -D CMAKE_C_FLAGS="-march=native -mtune=native" .. && \
    make -j ${NO_JOB} && \
    make install && \
    ldconfig && \
    rm -rf /project/opencv/build /project/opencv_contrib


# Stage 2: Create the final runtime image
FROM docker.io/arm64v8/ubuntu:22.04 as runtime

# Set ARGs and environment variables
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

ARG UID=1000
ARG GID=1000
ARG DEBIAN_FRONTEND=noninteractive
ENV USERNAME jetson
ENV HOME /home/$USERNAME

# add new sudo user
RUN useradd -m $USERNAME && \
    echo "$USERNAME:$USERNAME" | chpasswd && \
    usermod --shell /bin/bash $USERNAME && \
    usermod -aG sudo $USERNAME && \
    mkdir -p /etc/sudoers.d && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    usermod  --uid $UID $USERNAME && \
    groupmod --gid $GID $USERNAME && \
    gpasswd -a $USERNAME video

# NVIDIA repositories setup - installing gnupg first
RUN apt-get update && apt-get install -y --no-install-recommends wget gnupg2 ca-certificates && \
    echo "deb https://repo.download.nvidia.com/jetson/common r35.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    echo "deb https://repo.download.nvidia.com/jetson/t234 r35.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    wget -O /etc/jetson-ota-public.key https://gitlab.com/nvidia/container-images/l4t-base/-/raw/master/jetson-ota-public.key && \
    apt-key add /etc/jetson-ota-public.key

# Install required runtime packages in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    curl \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    iproute2 \
    iputils-ping \
    libudev1 \
    libvulkan1 \
    libzmq5 \
    python3 \
    python3-distutils \
    python3-numpy \
    python3-pip \
    python3-dev \
    sudo \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# EGL configuration
RUN echo "/usr/lib/aarch64-linux-gnu/tegra" >> /etc/ld.so.conf.d/nvidia-tegra.conf && \
    echo "/usr/lib/aarch64-linux-gnu/tegra-egl" >> /etc/ld.so.conf.d/nvidia-tegra.conf && \
    mkdir -p /usr/share/glvnd/egl_vendor.d/ && echo '\
{\
    "file_format_version" : "1.0.0",\
    "ICD" : {\
        "library_path" : "libEGL_nvidia.so.0"\
    }\
}' > /usr/share/glvnd/egl_vendor.d/10_nvidia.json && \
    mkdir -p /usr/share/egl/egl_external_platform.d/ && echo '\
{\
    "file_format_version" : "1.0.0",\
    "ICD" : {\
        "library_path" : "libnvidia-egl-wayland.so.1"\
    }\
}' > /usr/share/egl/egl_external_platform.d/nvidia_wayland.json

RUN echo "deb https://repo.download.nvidia.com/jetson/common r35.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    echo "deb https://repo.download.nvidia.com/jetson/t234 r35.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
RUN wget -O /etc/jetson-ota-public.key https://gitlab.com/nvidia/container-images/l4t-base/-/raw/master/jetson-ota-public.key && \
    apt-key add /etc/jetson-ota-public.key

# CUDA, cuDNN
RUN apt-get update && \
    apt-get install -qq -y --no-install-recommends \
    cuda-minimal-build-11-4 \
        libcudnn8 \
        libcudnn8-dev \
        #libcudnn8-samples \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy OpenCV libs from build stage
# Changed paths to match default OpenCV installation directory
COPY --from=build /usr/local/lib/libopencv* /usr/local/lib/
COPY --from=build /usr/local/include/opencv4 /usr/local/include/opencv4
COPY --from=build /usr/lib/python3*/dist-packages/cv2 /usr/local/lib/python3/dist-packages/cv2
COPY --from=build /usr/local/lib/cmake/opencv4 /usr/local/lib/cmake/opencv4
COPY --from=build /usr/local/lib/pkgconfig/opencv4.pc /usr/local/lib/pkgconfig/opencv4.pc

RUN ldconfig

# Install ROS2 Humble with minimal components
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ros-humble-ros-base \
    ros-humble-robot-localization \
    ros-humble-joint-state-publisher \
    ros-humble-xacro \
        ros-humble-rmw-cyclonedds-cpp \
        ros-humble-rosbag2-storage-mcap \
    ros-dev-tools \
    python3-colcon-common-extensions \
    python3-rosdep \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add specific ROS2 packages in a separate layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-nav2-bringup \
    ros-humble-nav2-bt-navigator \
    ros-humble-nav2-costmap-2d \
    ros-humble-nav2-core \
    ros-humble-nav2-map-server \
    ros-humble-rplidar-ros \
    ros-humble-xacro \
    ros-humble-usb-cam \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch to the user
USER $USERNAME
WORKDIR /home/$USERNAME
SHELL ["/bin/bash", "-l", "-c"]

# Configure environment
RUN echo "export PATH=/usr/local/cuda/bin:$PATH" >> ~/.bashrc && \
    echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/lib:$LD_LIBRARY_PATH" >> ~/.bashrc && \
    sudo rosdep init && \
    rosdep update && \
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc && \
    pip install --no-cache-dir pyquaternion && \
    echo "export LINOROBOT2_BASE=2wd" >> ~/.bashrc && \
    echo "export LINOROBOT2_LASER_SENSOR=a1" >> ~/.bashrc && \
    echo "source /project/linorobot2_ws/install/setup.bash" >> ~/.bashrc
