
#### weak-linking-example

Demonstrates the mechanics of a technique called "weak-linking" in a CMake
project (Mac OSX only).

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
  - static lib
    - s00: failure -- missing symbols
    - s01: success -- module pulls symbols from executable (ala Python)
    - s10: success -- executable pulls symbols from module
    - s11: failure -- duplicate symbols for sure (program output will be 0 0 1 1
      2 2 ..., instead of 0 1 2...).

  - dynamic lib
    - d00: failure -- missing symbols
    - d01: success -- module pulls symbols from executable (ala Python)
    - d10: success -- executable pulls symbols from module
    - d11: depends -- might get duplicate symbols (0 0 1 1 2 2 ... instead of 0
      1 2 ...). Depends on your platform.

