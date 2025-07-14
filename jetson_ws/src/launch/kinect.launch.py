from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    
    # Define o caminho direto para o arquivo de configuração do RViz DENTRO do container.
    rviz_config_file = '/root/ros_ws/src/config/kinect_config.rviz'

    # Define o nó para a câmera Kinect.
    kinect_node = Node(
        package='kinect_ros2',
        executable='kinect_ros2_node',
        name='kinect_camera',
        namespace='kinect'
    )

    # Define o nó para o RViz2, passando o caminho do arquivo de configuração.
    rviz_node = Node(
        package='rviz2',
        executable='rviz2',
        name='rviz2',
        arguments=['-d', rviz_config_file]
    )

    # Retorna a lista de nós que queremos iniciar.
    return LaunchDescription([
        kinect_node,
        rviz_node
    ])