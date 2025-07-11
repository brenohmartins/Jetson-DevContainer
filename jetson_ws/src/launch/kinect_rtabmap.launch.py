from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    return LaunchDescription([
        Node(
            package='kinect_ros2',
            namespace='kinect',
            executable='kinect_ros2_node',
            name='kinect_ros2'
        ),
    ]
)
