cmake_minimum_required(VERSION 3.16)

project(BlackBoxViewer LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/external/CanInitParser/cmake)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

add_compile_definitions(CANINIT_TEST_PATH="${CMAKE_CURRENT_LIST_DIR}/external/CanInitParser/CanInit.h")

add_subdirectory(src)
add_subdirectory(tests)
add_subdirectory(external)
