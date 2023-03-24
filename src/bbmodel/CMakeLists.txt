include(CompileOptions)

set(target_name BlackBoxViewer)

find_package(Qt5 REQUIRED COMPONENTS Core Quick REQUIRED)

add_library(${target_name} STATIC)
target_compile_definitions(${target_name} PRIVATE BLACKBOXVIEWER_LIBRARY)
target_sources(${target_name} PRIVATE blackboxviewer_global.h blackboxmodel.cpp blackboxmodel.h contextpool.h contextpool.cpp cannamesfinder.h cannamesfinder.cpp qmltypes.qrc)

target_link_libraries(${target_name} PRIVATE Qt5::Core Qt5::Quick)
target_link_libraries(${target_name} PRIVATE CanInitParser)

target_include_directories(${target_name} PUBLIC ${CMAKE_SOURCE_DIR}/external/CanInitParser/src/CanInitParser)

set(QML_IMPORT_PATH "${CMAKE_CURRENT_LIST_DIR}/qml" CACHE STRING "QT extra import path")

set_compile_options(${target_name})
