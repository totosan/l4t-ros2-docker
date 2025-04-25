#!/bin/bash
set -e

SKIP_PART=false

install_opencv () {
  
  # set all values for jetson nano
  model="Jetson Nano"
  model="Ubuntu"
  NO_JOB=4
  ARCH=5.3
  PTX="sm_53"


  echo "Installing OpenCV 4.11.0 on your Nano"
  echo "It will take 3.5 hours !"
  apt-get update

  # reveal the CUDA location
  cd ~
  sh -c "echo '/usr/local/cuda/lib64' >> /etc/ld.so.conf.d/nvidia-tegra.conf"
  ldconfig

# skip if false
  if [ "$SKIP_PART" = false ]; then
    
    # install the Jetson Nano dependencies first
    if [[ $model == *"Jetson Nano"* ]]; then
      apt-get install -y build-essential git unzip pkg-config zlib1g-dev
      apt-get install -y python3-dev python3-numpy
      #    apt-get install -y python-dev python-numpy
      apt-get install -y gstreamer1.0-tools libgstreamer-plugins-base1.0-dev
      apt-get install -y libgstreamer-plugins-good1.0-dev
      apt-get install -y libtbb2 libgtk-3-dev libxine2-dev
    fi
    
    if [ -f /etc/os-release ]; then
        # Source the /etc/os-release file to get variables
        . /etc/os-release
        # Extract the major version number from VERSION_ID
        VERSION_MAJOR=$(echo "$VERSION_ID" | cut -d'.' -f1)
        echo "Version ID is $VERSION_ID"
        echo "Version Major is $VERSION_MAJOR"
        # Check if the extracted major version is 22 or earlier
        if [ "$VERSION_MAJOR" = "22" ]; then
            apt-get install -y libswresample-dev libdc1394-dev
        else
      apt-get install -y libavresample-dev libdc1394-22-dev
        fi
    else
        apt-get install -y libavresample-dev libdc1394-22-dev
    fi


    echo "installing the common dependencies"
    # install the common dependencies
    apt-get install -y ccache
    apt-get install -y cmake
    apt-get install -y libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev
    apt-get install -y libpng-dev libtiff-dev libglew-dev
    apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
    apt-get install -y libgtk2.0-dev libgtk-3-dev libcanberra-gtk*
    apt-get install -y python3-pip
    apt-get install -y libxvidcore-dev libx264-dev
    apt-get install -y libtbb-dev libxine2-dev
    apt-get install -y libv4l-dev v4l-utils qv4l2
    apt-get install -y libtesseract-dev libpostproc-dev
    apt-get install -y libvorbis-dev
    apt-get install -y libfaac-dev libmp3lame-dev libtheora-dev
    apt-get install -y libopencore-amrnb-dev libopencore-amrwb-dev
    apt-get install -y libopenblas-dev libatlas-base-dev libblas-dev
    apt-get install -y liblapack-dev liblapacke-dev libeigen3-dev gfortran
    apt-get install -y libhdf5-dev libprotobuf-dev protobuf-compiler
    apt-get install -y libgoogle-glog-dev libgflags-dev
  

    # remove old versions or previous builds
    cd ~ 
    rm -rf opencv*
    # download the latest version
    git clone --depth=1 https://github.com/opencv/opencv.git
    git clone --depth=1 https://github.com/opencv/opencv_contrib.git
  fi
  # set install dir
  cd ~/opencv
  #exists build? skip mkdir
  if [ ! -d ~/opencv/build ]; then
    mkdir build
  fi
  cd build
  
  # run cmake
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -D CMAKE_C_COMPILER_LAUNCHER=ccache \
  -D CMAKE_INSTALL_PREFIX=/usr \
  -D BUILD_opencv_java=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D BUILD_DOCS=OFF \
  -D BUILD_ANDROID_EXAMPLES=OFF \
  -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
  -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
  -D WITH_OPENCL=OFF \
  -D WITH_OPENEXR=OFF \
  -D BUILD_OPENEXR=OFF \
  -D WITH_JASPER=OFF \
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
  -D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
  -D OPENCV_GENERATE_PKGCONFIG=ON \
  -D BUILD_EXAMPLES=OFF \
  -D CMAKE_CXX_FLAGS="-march=native -mtune=native" \
  -D CMAKE_C_FLAGS="-march=native -mtune=native" ..

  make -j ${NO_JOB} 
  
  directory="/usr/include/opencv4/opencv2"
  if [ -d "$directory" ]; then
    # Directory exists, so delete it
    rm -rf "$directory"
  fi
  
  make install
  ldconfig
  
  # cleaning (frees 320 MB)
  make clean
  apt-get update
  
  echo "Congratulations!"
  echo "You've successfully installed OpenCV 4.11.0 on your Nano"
}

cd ~

if [ -d ~/opencv/build ]; then
  echo " "
  echo "You have a directory ~/opencv/build on your disk."
  echo "Continuing the installation will replace this folder."
  echo " "
  

  if [ "$answer" != "${answer#[Nn]}" ] ;then 
      echo "Leaving without installing OpenCV"
  else
      install_opencv
  fi
else
    install_opencv
fi
