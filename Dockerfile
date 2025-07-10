FROM ros:jazzy

# As dependências são as mesmas, pois ambos os wrappers precisam do libfreenect e de ferramentas de build.
RUN apt-get update && apt-get install -y \
    vim git cmake build-essential pkg-config libusb-1.0-0-dev freeglut3-dev \
    python3-pip \
    ros-dev-tools \
    ros-jazzy-rtabmap-ros \
    ros-jazzy-rviz2 \
    ros-jazzy-camera-info-manager \
    ros-jazzy-depth-image-proc \
    ros-jazzy-image-tools \
    && rm -rf /var/lib/apt/lists/*

# comando para instalar o pyserial
#RUN pip3 install pyserial

WORKDIR /tmp
RUN GIT_TERMINAL_PROMPT=0 git clone https://github.com/OpenKinect/libfreenect.git && \
    cd libfreenect && \
    mkdir build && cd build && \
    # flag to dont build libfreenect -DBUILD_EXAMPLES=OFF -DBUILD_REDIST_PACKAGE=OFF
    cmake .. && \
    make && \
    make install && \
    ldconfig && \
    cd / && rm -rf /tmp/libfreenect


WORKDIR /root/ros_ws

# clones de pacotes ROS que irão ser tuilizados na jetson
RUN GIT_TERMINAL_PROMPT=0 git clone https://github.com/n1kn4x/xv11_lidar_python.git src/xv_11_driver
RUN GIT_TERMINAL_PROMPT=0 git clone https://github.com/fadlio/kinect_ros2.git src/kinect_ros2


# comando 'sed' encontra e substitui o texto no arquivo para garantir a compatibilidade com Jazzy.
RUN sed -i 's/cv_bridge.h/cv_bridge.hpp/g' src/kinect_ros2/include/kinect_ros2/kinect_ros2_component.hpp

# Executa o colcon build para compilar o pacote já corrigido.
RUN . /opt/ros/jazzy/setup.sh && colcon build

# configurando o terminal para carregar o ROS automaticamente.
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc && \
    echo "if [ -f /root/ros_ws/install/setup.bash ]; then source /root/ros_ws/install/setup.bash; fi" >> ~/.bashrc