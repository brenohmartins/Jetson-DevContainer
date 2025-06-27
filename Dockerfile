# chamanado a imagem oficial do ROS 2 Jazzy, que já vem com Ubuntu 24.04.
FROM ros:jazzy

# 2. Instalação de Dependências:
RUN apt-get update && apt-get install -y \
    vim \
    git \
    ros-dev-tools \
    ros-jazzy-turtlesim \
    # pacotes demo do ros jazzy para teste do ros no contianer para teste de ros
    ros-jazzy-demo-nodes-cpp \
    ros-jazzy-demo-nodes-py \
    # adiciona o rtab map
    ros-jazzy-rtabmap-ros \
    # adicona o rviz2
    ros-jazzy-rviz2 \
    && rm -rf /var/lib/apt/lists/*

# Criação do Workspace ROS: Define o local de trabalho dentro do container
WORKDIR /root/ros_ws

# Configuração do Ambiente: Garante que o ROS seja "sourceado" automaticamente
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
#verifica se o arquivo install/setup.bash existe, evita o erro quando você entra em um container pela primeira vez
RUN echo "if [ -f /root/ros_ws/install/setup.bash ]; then source /root/ros_ws/install/setup.bash; fi" >> ~/.bashrc