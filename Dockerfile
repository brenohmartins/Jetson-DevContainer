# --- ETAPA 1: IMAGEM BASE ---
FROM ros:jazzy

# --- ETAPA 2: INSTALAÇÃO DE DEPENDÊNCIAS DO SISTEMA ---
# As dependências são as mesmas, pois ambos os wrappers precisam do libfreenect e de ferramentas de build.
RUN apt-get update && apt-get install -y \
    vim git cmake build-essential pkg-config libusb-1.0-0-dev freeglut3-dev \
    ros-dev-tools \
    ros-jazzy-rtabmap-ros \
    ros-jazzy-rviz2 \
    ros-jazzy-camera-info-manager \
    # ADICIONE A DEPENDÊNCIA QUE FALTA AQUI:
    ros-jazzy-depth-image-proc \
    && rm -rf /var/lib/apt/lists/*

# --- ETAPA 3: COMPILAR E INSTALAR O DRIVER BASE (libfreenect) ---
# Esta etapa continua idêntica, pois ambos os pacotes ROS precisam desta biblioteca base.
WORKDIR /tmp
RUN GIT_TERMINAL_PROMPT=0 git clone https://github.com/OpenKinect/libfreenect.git && \
    cd libfreenect && \
    mkdir build && cd build && \
    cmake .. -DBUILD_EXAMPLES=OFF -DBUILD_REDIST_PACKAGE=OFF && \
    make && \
    make install && \
    ldconfig && \
    cd / && rm -rf /tmp/libfreenect

# --- ETAPA 4: PREPARAR, CORRIGIR E COMPILAR O WORKSPACE ROS ---
WORKDIR /root/ros_ws

# 4.1: Clona o repositório que você especificou na pasta src.
RUN GIT_TERMINAL_PROMPT=0 git clone https://github.com/fadlio/kinect_ros2.git src/kinect_ros2

# 4.2: CORREÇÃO AUTOMÁTICA: Aplica a correção do cv_bridge.h para .hpp
# Este comando 'sed' encontra e substitui o texto no arquivo para garantir a compatibilidade com Jazzy.
RUN sed -i 's/cv_bridge.h/cv_bridge.hpp/g' src/kinect_ros2/include/kinect_ros2/kinect_ros2_component.hpp

# 4.3: Executa o colcon build para compilar o pacote já corrigido.
RUN . /opt/ros/jazzy/setup.sh && colcon build

# --- ETAPA 5: CONFIGURAÇÃO FINAL DO AMBIENTE ---
# Continua igual, configurando o terminal para carregar o ROS automaticamente.
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc && \
    echo "if [ -f /root/ros_ws/install/setup.bash ]; then source /root/ros_ws/install/setup.bash; fi" >> ~/.bashrc