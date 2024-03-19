# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(ServoDemo)

# Dummy CMake.
add_library(simpleservo SHARED IMPORTED)
set_target_properties(simpleservo
    PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/libsimpleservo.so)

add_library(dummy SHARED dummy.cpp)
target_link_libraries(dummy PUBLIC simpleservo)
