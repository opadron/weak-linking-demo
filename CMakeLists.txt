cmake_minimum_required(VERSION 3.5.0)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

project(weak_linking_example C)

include(CTest)
enable_testing()

set(LIB_TYPE SHARED CACHE STRING "library type")
set(WEAK_LINK_MODULE true CACHE BOOL "weakly link module against library")
set(WEAK_LINK_EXE    false CACHE BOOL "weakly link executable against library")


# LIBRARY (number)
add_library(number ${LIB_TYPE} number.c)


# MODULE (counter)
add_library(counter MODULE counter.c)
set_target_properties(counter PROPERTIES PREFIX "")
if(WEAK_LINK_MODULE)
    set_target_properties(counter
                          PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
else()
    target_link_libraries(counter number)
endif()


# EXECUTABLE (main)
add_executable(main main.c)
if(WEAK_LINK_EXE)
    set_target_properties(main
                          PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
else()
    target_link_libraries(main number)
endif()

add_test(NAME main COMMAND main)

