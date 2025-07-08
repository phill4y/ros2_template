cmake_minimum_required(VERSION 3.22)
project(example_interfaces)

find_package(ament_cmake REQUIRED)
find_package(std_msgs REQUIRED)
find_package(rosidl_default_generators REQUIRED)

# Collect all .msg, .srv, and .action files.
file(
    GLOB_RECURSE ALL_MSGS
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "msg/*.msg")
file(
    GLOB_RECURSE ALL_SRVS
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "srv/*.srv")
file(
    GLOB_RECURSE ALL_ACTIONS
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "action/*.action")

# Pass the discovered files to rosidl_generate_interfaces()
rosidl_generate_interfaces(${PROJECT_NAME} ${ALL_MSGS} ${ALL_SRVS} ${ALL_ACTIONS} DEPENDENCIES std_msgs)

ament_export_dependencies(rosidl_default_runtime)
ament_package()
