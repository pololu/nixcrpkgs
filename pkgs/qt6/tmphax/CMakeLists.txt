cmake_minimum_required(VERSION 3.16)
project(tmphax LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

qt_standard_project_setup()
qt_add_executable(tmphax tmphax.cpp)
target_link_libraries(tmphax PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets)

install(TARGETS tmphax RUNTIME DESTINATION "bin")
