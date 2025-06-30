# --- ETAPA 1: IMAGEM BASE ---
# Começamos com a imagem oficial do ROS 2 Jazzy, que já vem com Ubuntu 24.04.
FROM ros:jazzy

# --- ETAPA 2: INSTALAÇÃO DE DEPENDÊNCIAS DO SISTEMA ---
# Instalamos o essencial para compilar o libfreenect com seus exemplos gráficos.
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    vim \
    build-essential \
    pkg-config \
    libusb-1.0-0-dev \
    freeglut3-dev \
    && rm -rf /var/lib/apt/lists/*

# --- ETAPA 3: COMPILAR E INSTALAR O DRIVER BASE (libfreenect) COM EXEMPLOS ---
# Isso garante que a biblioteca principal E os programas de teste do Kinect estejam disponíveis.
WORKDIR /tmp
RUN git clone https://github.com/OpenKinect/libfreenect.git && \
    cd libfreenect && \
    mkdir build && cd build && \
    # CORREÇÃO APLICADA: Removemos a flag -DBUILD_EXAMPLES=OFF para que o freenect-glview seja compilado.
    cmake .. && \
    make && \
    make install && \
    ldconfig && \
    cd / && rm -rf /tmp/libfreenect


# WORKDIR /root/ros_ws
# RUN git clone https://github.com/ros-drivers/freenect_camera.git -b ros2 src/freenect_camera
# RUN . /opt/ros/jazzy/setup.sh && colcon build

# --- ETAPA 5: CONFIGURAÇÃO FINAL DO AMBIENTE ---
# Apenas o source principal do ROS é suficiente por enquanto.
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc