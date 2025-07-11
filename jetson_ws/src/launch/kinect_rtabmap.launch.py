# Conteúdo para iniciar_kinect.launch.py

import os
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from ament_index_python.packages import get_package_share_directory

# Esta é a função principal que o ros2 launch procura
def generate_launch_description():

    # Encontra o caminho para o pacote do kinect que compilamos
    kinect_package_dir = get_package_share_directory('kinect_ros2')

    # Cria a ação de incluir o launch file do kinect
    # Estamos reutilizando o launch file que já vem com o driver
    start_kinect_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(kinect_package_dir, 'launch', 'showimage.launch.py')
        )
    )
    
    # Retorna a descrição do lançamento, contendo apenas a ação de iniciar o kinect
    return LaunchDescription([
        start_kinect_cmd
    ])