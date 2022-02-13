#!/bin/bash

# exit on error
set -e

# install git and build-essential
echo "Installing git and build-essentials"

sudo apt update && sudo apt install build-essential git python zip adb openjdk-8-jdk

# install build dependencies
echo "Installing build dependencies for opencv"

sudo apt install cmake ffmpeg libavformat-dev libdc1394-22-dev libgtk2.0-dev \
    libjpeg-dev libpng-dev libswscale-dev libtbb2 libtbb-dev \
    libtiff-dev libopenjp2-7-dev libtiff5-dev

# opencv version to install
opencv_version="4.5.5"
opencv_prefix="${PWD}/opencv"

echo "Installing opencv ${opencv_version} with prefix: ${opencv_prefix}"

# clone opencv
echo "Cloning opencv repositories"

git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
git clone https://github.com/opencv/opencv_3rdparty.git

cd opencv_contrib && git checkout ${opencv_version} && cd -
cd opencv && git checkout ${opencv_version} && cd -

# copy xfeatures2d descriptors beforehand
echo "Copying xfeatures2d descriptors"

opencv_3rdparty_commit_boostdesc="34e4206aef44d50e6bbcd0ab06354b52e7466d26"
opencv_3rdparty_commit_vgg="fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d"

dst_dir="${PWD}/opencv/release"

cd opencv_3rdparty

git checkout ${opencv_3rdparty_commit_boostdesc} && \
cp boostdesc_* ${dst_dir} && \
git switch -

git checkout ${opencv_3rdparty_commit_vgg} && \
cp vgg_* ${dst_dir} && \
git switch -

cd -

# build opencv
echo "Start building opencv"

root_dir="${PWD}"
cd opencv/release

cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=${opencv_prefix} \
    -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_opencv_ts=OFF \
    -DOPENCV_EXTRA_MODULES_PATH=${root_dir}/opencv_contrib/modules \
    -DBUILD_opencv_aruco=OFF -DBUILD_opencv_bgsegm=OFF -DBUILD_opencv_bioinspired=OFF \
    -DBUILD_opencv_ccalib=OFF -DBUILD_opencv_datasets=OFF -DBUILD_opencv_dnn=OFF \
    -DBUILD_opencv_dnn_objdetect=OFF -DBUILD_opencv_dpm=OFF -DBUILD_opencv_face=OFF \
    -DBUILD_opencv_fuzzy=OFF -DBUILD_opencv_hfs=OFF -DBUILD_opencv_img_hash=OFF \
    -DBUILD_opencv_js=OFF -DBUILD_opencv_line_descriptor=OFF -DBUILD_opencv_phase_unwrapping=OFF \
    -DBUILD_opencv_plot=OFF -DBUILD_opencv_quality=OFF -DBUILD_opencv_reg=OFF \
    -DBUILD_opencv_rgbd=OFF -DBUILD_opencv_saliency=OFF -DBUILD_opencv_shape=OFF \
    -DBUILD_opencv_structured_light=OFF -DBUILD_opencv_surface_matching=OFF \
    -DBUILD_opencv_world=OFF -DBUILD_opencv_xobjdetect=OFF -DBUILD_opencv_xphoto=OFF \
    -DBUILD_TIFF=ON -DCV_ENABLE_INTRINSICS=ON -DWITH_EIGEN=ON -DWITH_PTHREADS=ON -DWITH_PTHREADS_PF=ON \
    -DWITH_JPEG=ON -DWITH_PNG=ON -DWITH_TIFF=ON
make -j 16
sudo make install

cd -

echo "OpenCV has been built. You can find the header files and libraries in ${opencv_prefix}/include/opencv2/ and ${opencv_prefix}/lib"

# https://github.com/cggos/dip_cvqt/issues/1#issuecomment-284103343
echo "Generating file: /etc/ld.so.conf.d/mp_opencv.conf"

sudo touch /etc/ld.so.conf.d/mp_opencv.conf
sudo bash -c  "echo ${opencv_prefix}/lib >> /etc/ld.so.conf.d/mp_opencv.conf"
sudo ldconfig -v

# get mediapipe
echo "Clonning mediapipe repository"

git clone https://github.com/google/mediapipe.git
cd mediapipe

# prepare variables
opencv_build_file="${PWD}"/third_party/opencv_linux.BUILD
workspace_file="${PWD}"/WORKSPACE

# modif the build arg
echo "Modifying mediapipe opencv config"

sed -i "/linkopts/a \\ \\ \\ \\ \\ \\ \\ \\ \\\"-L${opencv_prefix}/lib\"," ${opencv_build_file}
linux_opencv_config=$(grep -n 'linux_opencv' ${workspace_file} | awk -F  ":" '{print $1}')
path_line=$((linux_opencv_config + 2))
sed -i "${path_line} d" ${workspace_file}
sed -i "${path_line} i\    path = \"${opencv_prefix}\"," $workspace_file

echo "Done"

