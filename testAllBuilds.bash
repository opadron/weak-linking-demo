#! /usr/bin/env bash

mkdir -p log

echo "CASE CONFIG BUILD TEST"

for lib_type in SHARED STATIC ; do
    if [ "$lib_type" '=' 'SHARED' ] ; then
        L='d'
    elif [ "$lib_type" '=' 'STATIC' ] ; then
        L='s'
    fi

    for link_mod in 0 1 ; do
        if [ "$link_mod" '=' '0' ] ; then
            weak_mod=1
        else
            weak_mod=0
        fi

        for link_exe in 0 1 ; do
            if [ "$link_exe" '=' '0' ] ; then
                weak_exe=1
            else
                weak_exe=0
            fi

            mkdir -p "_build/$L$link_mod$link_exe"
            pushd "_build/$L$link_mod$link_exe" > /dev/null 2>&1
            testcase=${L}${link_mod}${link_exe}

            mkdir -p "../../log/$testcase"

            cmake ../..                        \
                -DCMAKE_BUILD_TYPE="Release"   \
                -DLIB_TYPE="$lib_type"         \
                -DWEAK_LINK_MODULE="$weak_mod" \
                -DWEAK_LINK_EXE="$weak_exe"    \
                    &> "../../log/$testcase/configure.txt"
            configure_result="$?"

            make &> "../../log/$testcase/build.txt"
            build_result="$?"

            make test &> "../../log/$testcase/test.txt"
            test_result="$?"

            code=32
            result=pass
            if [ "$configure_result" '!=' '0' ] ; then
                code=31
                result=fail
            fi
            configure_result="\\e[1;${code}m${result}\\e[0m"
            configure_result="$( echo -e "$configure_result" )"

            code=32
            result=pass
            if [ "$build_result" '!=' '0' ] ; then
                code=31
                result=fail
            fi
            build_result="\\e[1;${code}m${result}\\e[0m"
            build_result="$( echo -e "$build_result" )"

            code=32
            result=pass
            if [ "$test_result" '!=' '0' ] ; then
                code=31
                result=fail
            fi
            test_result="\\e[1;${code}m${result}\\e[0m"
            test_result="$( echo -e "$test_result" )"

            echo "$testcase  $configure_result   $build_result  $test_result"

            popd > /dev/null 2>&1
        done
    done
done

