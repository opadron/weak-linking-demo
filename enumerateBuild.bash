#! /usr/bin/env bash

mkdir -p log

interactive=false
if [ "$#" '=' '0' ] ; then
    echo "Please, type case identifier (e.g d00)"
    echo ""
    interactive=true
fi

echo "CASE  CONFIG BUILD  TEST"

if [ "$interactive" '=' true ] ; then
    cat
else
    while [ "$#" '!=' '0' ] ; do
        echo "$1" ; shift
    done
fi | while read testcase ; do

    if [ "$testcase" '=' '' ]; then
        continue
    fi

    if [ "${testcase:0:1}" '=' 's' ] ; then
        lib_type="STATIC"
    elif [ "${testcase:0:1}" '=' 'd' ] ; then
        lib_type="SHARED"
    else
        msg="unrecognized test case: $testcase"
        [[ $interactive ]] && echo $msg || echo $msg >&2
        exit 1
    fi

    weak_link_mod="$(( 1 - ${testcase:1:1} ))"
    weak_link_exe="$(( 1 - ${testcase:2:1} ))"

    mkdir -p "_build/$testcase"
    mkdir -p "log/$testcase"
    pushd "_build/$testcase" &> /dev/null

    cmake ../..                             \
        -DCMAKE_BUILD_TYPE="Release"        \
        -DLIB_TYPE="$lib_type"              \
        -DWEAK_LINK_MODULE="$weak_link_mod" \
        -DWEAK_LINK_EXE="$weak_link_exe"    \
            &> "../../log/$testcase/configure.txt"
    configure_result="$?"

    make VERBOSE=1 &> "../../log/$testcase/build.txt"
    build_result="$?"

    ./main &> "../../log/$testcase/test.txt"
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

        result="RTE"

        if [ "$test_result" '=' '250' ] ; then # wrong answer
            result="DSYM"
        elif [ "$test_result" '=' '251' ] ; then # dl load error
            result="DLLF"
        fi
    fi
    test_result="\\e[1;${code}m${result}\\e[0m"
    test_result="$( echo -e "$test_result" )"

    echo "$testcase   $configure_result   $build_result   $test_result"

    popd &> /dev/null
done 2> /dev/null

