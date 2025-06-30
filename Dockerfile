# --- ETAPA 1: IMAGEM BASE ---
# Começamos com a imagem oficial do ROS 2 Jazzy, que já vem com Ubuntu 24.04 para a arquitetura ARM64.
FROM ros:jazzy

# --- ETAPA 2: INSTALAÇÃO DE DEPENDÊNCIAS DO SISTEMA ---
# Instalamos todas as ferramentas e bibliotecas que precisaremos para compilar TUDO do zero.
RUN apt-get update && apt-get install -y \
    vim git cmake build-essential pkg-config libusb-1.0-0-dev freeglut3-dev \
    ros-dev-tools ros-jazzy-rtabmap-ros ros-jazzy-rviz2 ros-jazzy-camera-info-manager \
    && rm -rf /var/lib/apt/lists/*

# --- ETAPA 3: COMPILAR E INSTALAR O DRIVER BASE (libfreenect) ---
# Isso garante que a biblioteca principal do Kinect esteja disponível para todo o sistema dentro do container.
WORKDIR /tmp
# CORREÇÃO: Usando https:// para compatibilidade máxima com a rede.
RUN git clone https://github.com/OpenKinect/libfreenect.git && \
    cd libfreenect && \
    mkdir build && cd build && \
    cmake .. -DBUILD_EXAMPLES=OFF -DBUILD_REDIST_PACKAGE=OFF && \
    make && \
    make install && \
    ldconfig && \
    cd / && rm -rf /tmp/libfreenect

# --- ETAPA 4: PREPARAR E COMPILAR O WORKSPACE ROS ---
# Define o nosso workspace de trabalho final
WORKDIR /root/ros_ws

# Clona o pacote ROS freenect_camera (o wrapper) na pasta src do nosso workspace
# CORREÇÃO: Usando https:// para compatibilidade máxima com a rede.
RUN git clone https://github.com/ros-drivers/freenect_camera.git -b ros2 src/freenect_camera

# Executa o colcon build para compilar o freenect_camera.
RUN . /opt/ros/jazzy/setup.sh && colcon build

# --- ETAPA 5: CONFIGURAÇÃO FINAL DO AMBIENTE ---
# Configura o terminal para já ter o ROS ativado por padrão, incluindo nosso workspace local já compilado.
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc && \
    echo "if [ -f /root/ros_ws/install/setup.bash ]; then source /root/ros_ws/install/setup.bash; fi" >> ~/.bashrc