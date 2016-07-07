
#include <stdlib.h>
#include <stdio.h>
#include <dlfcn.h>

#include <number.h>

int my_count() {
    int result = get_number();
    set_number(result + 1);
    return result;
}

int main(int argc, char **argv) {
    void *counter_module;
    int (*count)(void);
    int i, n;
    int result;

    counter_module = dlopen("./counter.so", RTLD_LAZY | RTLD_GLOBAL);
    if(!counter_module) goto error;

    count = dlsym(counter_module, "count");
    if(!count) goto error;

    result = 0;
    for(i=0; i<10; ++i) {
        n = ((i%2) ? count : my_count)();
        result = (result || n != i) ? 250 : 0;
        printf("%d\n", n);
    }

    goto done;
    error:
        fprintf(stderr, "Error occured:\n    %s\n", dlerror());
        result = 251;

    done:
        if(counter_module) dlclose(counter_module);
        return result;
}

