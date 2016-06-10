#! /usr/bin/env bash

echo "<LIB_TYPE><LINK_MOD><LINK_EXE>"
echo "LIB_TYPE: d -> SHARED, s-> STATIC"
echo "LINK_MOD: 1 -> weak, 0 -> strong"
echo "LINK_EXE: 1 -> weak, 0 -> strong"
echo ""

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

            cmake ../.. -DLIB_TYPE="$lib_type"         \
                        -DWEAK_LINK_MODULE="$weak_mod" \
                        -DWEAK_LINK_EXE="$weak_exe" > $testcase_configure_log.txt 2>&1
            if [[ $? == 0 ]]; then
              echo "$testcase [configure success]"
            else
              echo "$testcase [configure failure]"
            fi

            make > $testcase_build_log.txt 2>&1
            if [[ $? == 0 ]]; then
              echo "$testcase [build ... success]"
            else
              echo "$testcase [build ... failure]"
            fi

            popd > /dev/null 2>&1
        done
    done
done

