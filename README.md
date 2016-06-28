
#### weak-linking-example

Demonstrates the mechanics of a technique called "weak-linking" in a CMake
project (Linux and Mac OSX).

Application is split into three parts:
  - Library implementing `set_number()` and `get_number()` for a hidden, shared
    variable.

  - Counter module that uses the Library to expose a counting API.
    `count()` returns successively greater integers.

  - Main executable
    - Uses two different counting functions to print 10 numbers.
    - First is the `count()` function loaded at runtime from the Counter module
    - The other is its own count function that uses the same Number library used
      by the Counter module.

Dependency graph looks like this:
```
  [LIB]
  /   \
 V     |
[MOD]  |
 |     |
 \     V
  \->[EXE]
```

#### Instructions

```
git clone git://github.com/opadron/weak-linking-demo
cd weak-linking-demo
./testAllBuilds.bash
```

Will create a build for every combination of the relevant variables: whether to
build the LIB statically (s) or dynamically (d), whether to normally link it
into the MOD (1) or to weakly link it (0), and whether to normally link it into
the EXE (1) or to weakly link it (0).

```
./enumerateBuild.bash d01
  or
./runBuild.bash d01
```

Will test (or run) the build that was configured to build the LIB dynamically
(d), normally link it into the MOD (1), and weakly link it into the EXE (0).
Replace "d10" with your desired combination to run that particular build.

##### Expected Results

NOTE: This demo performs two series of host examinations.  The first is to
determine if the host system supports weak linking.  The second is to determine
if the dynamic loader can properly merge symbol entries that have been
duplicated across link boundaries (e.g: Linux).  Even if the host is found to
not support weak linking, the "weak link" operation would still succeed if the
loader can cope with duplicate symbols.  In this case, the link is silently
promoted to a proper linking.

###### Linux (GCC)

|CASE|CONFIG            |BUILD             |TEST              |NOTES|
|----|------------------|------------------|------------------|----:|
|s00 |:white_check_mark:|:white_check_mark:|:x:               |  1,2|
|s01 |:white_check_mark:|:white_check_mark:|:x:               |  1,2|
|s10 |:white_check_mark:|:white_check_mark:|:x:               |  1,2|
|s11 |:white_check_mark:|:white_check_mark:|:x:               |  1,2|
|d00 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    1|
|d01 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    1|
|d10 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    1|
|d11 |:white_check_mark:|:white_check_mark:|:white_check_mark:|  1,6|

###### OSX (XCODE)

|CASE|CONFIG            |BUILD             |TEST              |NOTES|
|----|------------------|------------------|------------------|-----|
|s00 |:white_check_mark:|:white_check_mark:|:x:               |    3|
|s01 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    4|
|s10 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    5|
|s11 |:white_check_mark:|:white_check_mark:|:x:               |    2|
|d00 |:white_check_mark:|:white_check_mark:|:x:               |    3|
|d01 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    4|
|d10 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    5|
|d11 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    6|

###### NOTES

  1. On Linux, the only thing that matters is whether the library in question is
  shared or static.  The dynamic loader doesn't seem to have any problems with
  multiple identical symbols.

  1. Test case fails unique symbols test (program output looks like
  `0 0 1 1 2 2 ...` instead of `0 1 2 ...`).

  1. Test fails due to unresolved symbols.

  1. Module pulls symbols from the executable (ala Python extension modules).

  1. Executable pulls symbols from the module (unusual, but it works).

  1. Duplicate symbols are successfully resolved and unified at load time.

