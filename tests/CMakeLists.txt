include(CompileOptions)

set(target_name BlackBoxViewerTest)

find_package(
  Qt5 REQUIRED
  COMPONENTS Core Quick
  REQUIRED)

add_executable(${target_name} main.cpp qml.qrc)

target_link_libraries(${target_name} PRIVATE Qt5::Core Qt5::Quick)
target_link_libraries(${target_name} PRIVATE BlackBoxViewer CanInitParser)

target_include_directories(${target_name} PUBLIC ${CMAKE_SOURCE_DIR}/src/bbmodel)

set_target_properties(${target_name} PROPERTIES WIN32_EXECUTABLE ON)
