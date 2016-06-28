cmake_minimum_required(VERSION 3.5.0)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

project(weak_linking_example C)

include(CTest)
enable_testing()

if(NOT DEFINED CAN_DOUBLE_LINK)
    set(TC_SRC_DIR
        "${CMAKE_BINARY_DIR}/try_compile_src/double-link")
    set(TC_BIN_DIR
        "${CMAKE_BINARY_DIR}/try_compile_build/double-link")

    file(MAKE_DIRECTORY ${TC_SRC_DIR})
    file(MAKE_DIRECTORY ${TC_BIN_DIR})

    file(WRITE "${TC_SRC_DIR}/CMakeLists.txt" "
        cmake_minimum_required(VERSION ${CMAKE_VERSION})
        include_directories(${TC_SRC_DIR})
        project(double_link_try C)

        add_library(number SHARED number.c)

        add_library(counter MODULE counter.c)
        set_target_properties(counter PROPERTIES PREFIX \"\")
        target_link_libraries(counter number)

        add_executable(main main.c)
        target_link_libraries(main number)
        target_link_libraries(main ${CMAKE_DL_LIBS})

        install(TARGETS number  LIBRARY DESTINATION \"${TC_BIN_DIR}\")
        install(TARGETS counter LIBRARY DESTINATION \"${TC_BIN_DIR}\")
        install(FILES   main            DESTINATION \"${TC_BIN_DIR}\")
    ")

    file(WRITE "${TC_SRC_DIR}/number.c" "
        #include <number.h>

        static int _number;
        void set_number(int number) { _number = number; }
        int get_number() { return _number; }
    ")

    file(WRITE "${TC_SRC_DIR}/number.h" "
        #ifndef _NUMBER_H
        #define _NUMBER_H
        extern void set_number(int);
        extern int get_number(void);
        #endif
    ")

    file(WRITE "${TC_SRC_DIR}/counter.c" "
        #include <number.h>
        int count() {
            int result = get_number();
            set_number(result + 1);
            return result;
        }
    ")

    file(WRITE "${TC_SRC_DIR}/counter.h" "
        #ifndef _COUNTER_H
        #define _COUNTER_H
        extern int count(void);
        #endif
    ")

    file(WRITE "${TC_SRC_DIR}/main.c" "
        #include <stdlib.h>
        #include <stdio.h>
        #include <dlfcn.h>

        int my_count() {
            int result = get_number();
            set_number(result + 1);
            return result;
        }

        int main(int argc, char **argv) {
            void *counter_module;
            int (*count)(void);
            int result;

            counter_module = dlopen(\"./counter.so\", RTLD_LAZY);
            if(!counter_module) goto error;

            count = dlsym(counter_module, \"count\");
            if(!count) goto error;

            result = count()    != 0 ? 1 :
                     my_count() != 1 ? 1 :
                     my_count() != 2 ? 1 :
                     count()    != 3 ? 1 :
                     count()    != 4 ? 1 :
                     count()    != 5 ? 1 :
                     my_count() != 6 ? 1 : 0;


            goto done;
            error:
                fprintf(stderr, \"Error occured:\\n    %s\\n\", dlerror());
                result = 1;

            done:
                if(counter_module) dlclose(counter_module);
                return result;
        }
    ")

    try_compile(double_link_compiles
                "${TC_BIN_DIR}"
                "${TC_SRC_DIR}"
                "double_link_try")

    set(double_link_works 1)
    if(double_link_compiles)
        execute_process(COMMAND "${TC_BIN_DIR}/main"
                        WORKING_DIRECTORY "${TC_BIN_DIR}"
                        RESULT_VARIABLE double_link_works)
    endif()

    if(double_link_works EQUAL 0)
        set(double_link_works TRUE)
    else()
        set(double_link_works FALSE)
    endif()

    set(CAN_DOUBLE_LINK
        ${double_link_works} CACHE BOOL "ok to double link")
endif()


IF(NOT DEFINED HAS_DYNAMIC_LOOKUP)
    set(TC_SRC_DIR
        "${CMAKE_BINARY_DIR}/try_compile_src/dynamic-lookup")
    set(TC_BIN_DIR
        "${CMAKE_BINARY_DIR}/try_compile_build/dynamic-lookup")

    file(MAKE_DIRECTORY ${TC_SRC_DIR})
    file(MAKE_DIRECTORY ${TC_BIN_DIR})

    file(WRITE "${TC_SRC_DIR}/CMakeLists.txt" "
        cmake_minimum_required(VERSION ${CMAKE_VERSION})
        include_directories(${TC_SRC_DIR})
        project(dynamic_lookup_try C)

        add_library(number SHARED number.c)

        add_library(counter MODULE counter.c)
        set_target_properties(counter PROPERTIES PREFIX \"\")
        set_target_properties(
            counter
            PROPERTIES LINK_FLAGS \"-undefined dynamic_lookup\")

        add_executable(main main.c)
        target_link_libraries(main number)
        target_link_libraries(main ${CMAKE_DL_LIBS})

        install(TARGETS number  LIBRARY DESTINATION \"${TC_BIN_DIR}\")
        install(TARGETS counter LIBRARY DESTINATION \"${TC_BIN_DIR}\")
        install(FILES   main            DESTINATION \"${TC_BIN_DIR}\")
    ")

    file(WRITE "${TC_SRC_DIR}/number.c" "
        #include <number.h>

        static int _number;
        void set_number(int number) { _number = number; }
        int get_number() { return _number; }
    ")

    file(WRITE "${TC_SRC_DIR}/number.h" "
        #ifndef _NUMBER_H
        #define _NUMBER_H
        extern void set_number(int);
        extern int get_number(void);
        #endif
    ")

    file(WRITE "${TC_SRC_DIR}/counter.c" "
        #include <number.h>
        int count() {
            int result = get_number();
            set_number(result + 1);
            return result;
        }
    ")

    file(WRITE "${TC_SRC_DIR}/counter.h" "
        #ifndef _COUNTER_H
        #define _COUNTER_H
        extern int count(void);
        #endif
    ")

    file(WRITE "${TC_SRC_DIR}/main.c" "
        #include <stdlib.h>
        #include <stdio.h>
        #include <dlfcn.h>

        int my_count() {
            int result = get_number();
            set_number(result + 1);
            return result;
        }

        int main(int argc, char **argv) {
            void *counter_module;
            int (*count)(void);
            int result;

            counter_module = dlopen(\"./counter.so\", RTLD_LAZY);
            if(!counter_module) goto error;

            count = dlsym(counter_module, \"count\");
            if(!count) goto error;

            result = count()    != 0 ? 1 :
                     my_count() != 1 ? 1 :
                     my_count() != 2 ? 1 :
                     count()    != 3 ? 1 :
                     count()    != 4 ? 1 :
                     count()    != 5 ? 1 :
                     my_count() != 6 ? 1 : 0;


            goto done;
            error:
                fprintf(stderr, \"Error occured:\\n    %s\\n\", dlerror());
                result = 1;

            done:
                if(counter_module) dlclose(counter_module);
                return result;
        }
    ")

    try_compile(dynamic_lookup_compiles
                "${TC_BIN_DIR}"
                "${TC_SRC_DIR}"
                "dynamic_lookup_try")

    set(dynamic_lookup_works 1)
    if(dynamic_lookup_compiles)
        execute_process(COMMAND "${TC_BIN_DIR}/main"
                        WORKING_DIRECTORY "${TC_BIN_DIR}"
                        RESULT_VARIABLE dynamic_lookup_works)
    endif()

    if(dynamic_lookup_works EQUAL 0)
        set(dynamic_lookup_works TRUE)
    else()
        set(dynamic_lookup_works FALSE)
    endif()

    set(HAS_DYNAMIC_LOOKUP ${dynamic_lookup_works}
        CACHE BOOL "linker supports dynamic_lookup")
endif()


function(target_weak_link_libraries target)
    if(HAS_DYNAMIC_LOOKUP)
        set_target_properties(${target}
                              PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
    elseif(CAN_DOUBLE_LINK)
        target_link_libraries(${target} ${ARGN})
    else()
        message(FATAL_ERROR "Cannot weak link target: ${target}")
    endif()
endfunction()


set(LIB_TYPE         SHARED CACHE STRING "library type")
set(WEAK_LINK_MODULE TRUE   CACHE BOOL "weakly link module against library")
set(WEAK_LINK_EXE    FALSE  CACHE BOOL "weakly link executable against library")


# LIBRARY (number)
add_library(number ${LIB_TYPE} number.c)


# MODULE (counter)
add_library(counter MODULE counter.c)
set_target_properties(counter PROPERTIES PREFIX "")
if(WEAK_LINK_MODULE)
    target_weak_link_libraries(counter number)
else()
    target_link_libraries(counter number)
endif()


# EXECUTABLE (main)
add_executable(main main.c)
if(WEAK_LINK_EXE)
    target_weak_link_libraries(main number)
else()
    target_link_libraries(main number)
endif()
target_link_libraries(main ${CMAKE_DL_LIBS})

add_test(NAME main COMMAND main)

