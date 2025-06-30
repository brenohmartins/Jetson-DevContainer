# --- ETAPA 1: IMAGEM BASE ---
# Começamos com a imagem oficial do ROS 2 Jazzy, que já vem com Ubuntu 24.04 para a arquitetura ARM64.
FROM ros:jazzy

# --- ETAPA 2: INSTALAÇÃO DE DEPENDÊNCIAS DO SISTEMA ---
# Instalamos todas as ferramentas e bibliotecas que precisaremos para compilar TUDO do zero.
RUN apt-get update && apt-get install -y \
    # Ferramentas básicas de desenvolvimento
    git \
    cmake \
    vim \
    build-essential \
    pkg-config \
    libusb-1.0-0-dev \
    freeglut3-dev \
    # Ferramentas do ROS
    ros-dev-tools \
    # Pacotes ROS que usaremos ou que são dependências
    ros-jazzy-rtabmap-ros \
    ros-jazzy-rviz2 \
    ros-jazzy-camera-info-manager \
    # Limpa o cache do apt para manter a imagem pequena
    && rm -rf /var/lib/apt/lists/*

# Isso garante que a biblioteca principal do Kinect esteja disponível para todo o sistema dentro do container.
# Usamos uma pasta temporária que será removida para não sujar a imagem final.
WORKDIR /tmp
# dependencias do libfreenect
RUN git clone git://github.com/OpenKinect/libfreenect.git && \
    cd libfreenect && \
    mkdir build && cd build && \
    cmake .. -DBUILD_EXAMPLES=OFF -DBUILD_REDIST_PACKAGE=OFF && \
    make && \
    make install && \
    ldconfig && \
    cd / && rm -rf /tmp/libfreenect

# Define o nosso workspace de trabalho final
WORKDIR /root/ros_ws

# Clona o pacote ROS freenect_camera (o wrapper) na pasta src do nosso workspace
RUN git clone git://github.com/ros-drivers/freenect_camera.git -b ros2 src/freenect_camera

# Executa o colcon build para compilar o freenect_camera e qualquer outro pacote que você colocar na pasta src.
# O 'source' garante que o ambiente ROS está ativo para a compilação.
RUN . /opt/ros/jazzy/setup.sh && colcon build

# --- ETAPA 5: CONFIGURAÇÃO FINAL DO AMBIENTE ---
# Configura o terminal para já ter o ROS ativado por padrão, incluindo nosso workspace local já compilado.
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc && \
    echo "if [ -f /root/ros_ws/install/setup.bash ]; then source /root/ros_ws/install/setup.bash; fi" >> ~/.bashrc