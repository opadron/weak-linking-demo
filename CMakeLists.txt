cmake_minimum_required(VERSION 3.5.0)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

project(weak_linking_example C)

include(CTest)
enable_testing()

set(LIB_TYPE SHARED CACHE STRING "library type")
set(WEAK_LINK_MODULE true CACHE BOOL "weakly link module against library")
set(WEAK_LINK_EXE    false CACHE BOOL "weakly link executable against library")

# XXX Add try_compile test ?
set(DYNAMIC_LOOKUP_SUPPORTED ${APPLE})

set(msg "Link flag '-undefined dynamic_lookup' supported")
if(DYNAMIC_LOOKUP_SUPPORTED)
  message(STATUS "${msg} - yes")
else()
  message(STATUS "${msg} - no")
endif()

# LIBRARY (number)
add_library(number ${LIB_TYPE} number.c)


# MODULE (counter)
add_library(counter MODULE counter.c)
set_target_properties(counter PROPERTIES PREFIX "")
if(WEAK_LINK_MODULE)
    if(DYNAMIC_LOOKUP_SUPPORTED)
        set_target_properties(counter
                              PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
    endif()
else()
    target_link_libraries(counter number)
endif()


# EXECUTABLE (main)
add_executable(main main.c)
if(WEAK_LINK_EXE)
    if(DYNAMIC_LOOKUP_SUPPORTED)
        set_target_properties(main
                              PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
    endif()
else()
    target_link_libraries(main number)
endif()

add_test(NAME main COMMAND main)

