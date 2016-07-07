
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

Add CMake >= 3.5 in your PATH

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

NOTE: The test step of the demo can fail for a number of reasons.  Their
abbreviations and meanings are: `RTE` for "runtime error", `DSYM` for "duplicate
symbols", and `DLLF` for "dynamic library load failure".

###### Linux (GCC)

|CASE|CONFIG            |BUILD             |TEST              |NOTES|
|----|------------------|------------------|------------------|----:|
|s00 |:white_check_mark:|:white_check_mark:|:x:RTE            |  1,2|
|s01 |:white_check_mark:|:white_check_mark:|:x:DSYM           |    3|
|s10 |:white_check_mark:|:white_check_mark:|:x:RTE            |    2|
|s11 |:white_check_mark:|:white_check_mark:|:x:DSYM           |    4|
|d00 |:white_check_mark:|:white_check_mark:|:x:RTE            |    2|
|d01 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    5|
|d10 |:white_check_mark:|:white_check_mark:|:x:RTE            |    2|
|d11 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    7|

###### OSX (XCODE)

|CASE|CONFIG            |BUILD             |TEST              |NOTES|
|----|------------------|------------------|------------------|-----|
|s00 |:white_check_mark:|:white_check_mark:|:x:RTE            |    1|
|s01 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    5|
|s10 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    6|
|s11 |:white_check_mark:|:white_check_mark:|:x:DSYM           |    4|
|d00 |:white_check_mark:|:white_check_mark:|:x:RTE            |    1|
|d01 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    5|
|d10 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    6|
|d11 |:white_check_mark:|:white_check_mark:|:white_check_mark:|    7|

###### NOTES

  1. Test fails due to unresolved symbols.

  1. On Linux, all symbols in a binary's namespace must be resolved when the
     namespace is instantiated.  Because of this requirement, leaving symbols
     unresolved in an executable is almost never useful, since the missing
     symbols must be provided before the executable is even ran (e.g.: using
     `LD_PRELOAD`).

  1. In the actual system test, the produced binary fails due to unresolved
     symbols in the module's namespace.  The result is reported as symbol
     duplication because the check falls back to double-linking in an attempt to
     produce a working executable (with the same result as the `s11` case).

  1. Test case fails unique symbols test (program output looks like
    `0 0 1 1 2 2 ...` instead of `0 1 2 ...`).

  1. Module pulls symbols from the executable (ala Python extension modules).

  1. Executable pulls symbols from the module (unusual, but it works).

  1. Duplicate symbols are successfully resolved and coalesced at load time.

