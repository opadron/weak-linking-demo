#! /usr/bin/env bash

# Usage:
#
#   colorized_message <exit_code> <text>
#
# Description:
#
#   If exit_code is 0, text is displayed in green.
#   Otherwise it is displayed in red.
#
colorized_message() {
    local exit_code=$1
    local text=$2
    code=32 # green
    [[ $exit_code != 0 ]] && code=31 # red
    text="\\e[1;${code}m${text}\\e[0m"
    echo -e "$text"
}

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
        [[ $interactive ]] && echo $(colorized_message 1 "$msg") || echo $msg >&2
        exit 1
    fi

    weak_link_mod="$(( 1 - ${testcase:1:1} ))"
    weak_link_exe="$(( 1 - ${testcase:2:1} ))"

    mkdir -p "_build/$testcase"
    mkdir -p "log/$testcase"
    pushd "_build/$testcase" &> /dev/null

    # configure
    cmake ../..                             \
        -DCMAKE_BUILD_TYPE="Release"        \
        -DLIB_TYPE="$lib_type"              \
        -DWEAK_LINK_MODULE="$weak_link_mod" \
        -DWEAK_LINK_EXE="$weak_link_exe"    \
            &> "../../log/$testcase/configure.txt"
    configure_result="$?"
    [[ $configure_result == 0 ]] && result="pass" || result="fail"
    configure_result=$(colorized_message $configure_result $result)

    # build
    make VERBOSE=1 &> "../../log/$testcase/build.txt"
    build_result="$?"
    [[ $build_result == 0 ]] && result="pass" || result="fail"
    build_result=$(colorized_message $build_result $result)

    # test
    ./main &> "../../log/$testcase/test.txt"
    test_result="$?"
    result=pass
    if [ "$test_result" '!=' '0' ] ; then
        result="RTE"

        if [ "$test_result" '=' '250' ] ; then # wrong answer
            result="DSYM"
        elif [ "$test_result" '=' '251' ] ; then # dl load error
            result="DLLF"
        fi
    fi
    test_result=$(colorized_message $test_result $result)

    # summary
    echo "$testcase   $configure_result   $build_result   $test_result"

    popd &> /dev/null
done 2> /dev/null

