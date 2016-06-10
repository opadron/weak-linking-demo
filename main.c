
#include <stdlib.h>
#include <stdio.h>
#include <defer.h>

#include <dlfcn.h>

#include <number.h>

int my_count() {
    int result = get_number();
    set_number(result + 1);
    return result;
}

int main(int argc, char **argv) {
    int i;
    void *counter_module;
    int (*count)(void);

    counter_module = dlopen("counter.so", 0);
    DEFER dlclose(counter_module);

    count = dlsym(counter_module, "count");

    for(i=0; i<10; ++i) {
        printf("%d\n", (i%2 ? count() : my_count()));
    }

    FULFILL;
    return EXIT_SUCCESS;
}

