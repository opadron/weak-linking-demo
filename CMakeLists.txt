cmake_minimum_required(VERSION 3.5.0)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

project(weak_linking_example C)

include(CTest)
enable_testing()

include(targetLinkLibrariesWithDynamicLookup.cmake)

set(LIB_TYPE         SHARED CACHE STRING "library type")
set(WEAK_LINK_MODULE TRUE   CACHE BOOL "weakly link module against library")
set(WEAK_LINK_EXE    FALSE  CACHE BOOL "weakly link executable against library")


# LIBRARY (number)
add_library(number ${LIB_TYPE} number.c)


# MODULE (counter)
add_library(counter MODULE counter.c)
set_target_properties(counter PROPERTIES PREFIX "")
if(WEAK_LINK_MODULE)
    target_link_libraries_with_dynamic_lookup(counter number)
else()
    target_link_libraries(counter number)
endif()

# Sanity check
get_target_property(mod_link_libs counter INTERFACE_LINK_LIBRARIES)
list(FIND mod_link_libs number is_mod_link_against_number)
if(WEAK_LINK_MODULE AND NOT is_mod_link_against_number EQUAL -1)
    message(FATAL_ERROR "Weak linking failed. LIB is NOT expected to be in MOD link libraries")
endif()


# EXECUTABLE (main)
add_executable(main main.c)
if(WEAK_LINK_EXE)
    target_link_libraries_with_dynamic_lookup(main number)
else()
    target_link_libraries(main number)
endif()
target_link_libraries(main ${CMAKE_DL_LIBS})

# Sanity check
get_target_property(exe_link_libs main INTERFACE_LINK_LIBRARIES)
list(FIND exe_link_libs number is_exe_link_against_number)
if(WEAK_LINK_EXE AND NOT is_exe_link_against_number EQUAL -1)
    message(FATAL_ERROR "Weak linking failed. LIB is NOT expected to be in EXE link libraries")
endif()

add_test(NAME main COMMAND main)

