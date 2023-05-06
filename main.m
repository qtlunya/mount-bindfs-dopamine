#import <dlfcn.h>
#import <stdio.h>
#import <sys/mount.h>
#import <sys/param.h>
#import <unistd.h>

#define LIBJAILBREAK_PATH "/var/jb/usr/lib/libjailbreak.dylib"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        if (argc != 3) {
            fprintf(stderr, "usage: %s <source> <target>\n", argv[0]);
            return 1;
        }

        if (access(LIBJAILBREAK_PATH, F_OK) != 0) {
            fprintf(stderr, "error: libjailbreak not found\n");
            return 1;
        }

        void *libjailbreak = dlopen(LIBJAILBREAK_PATH, RTLD_NOW);

        int (*jbdInitPPLRW)(void) = dlsym(libjailbreak, "jbdInitPPLRW");
        void (*run_unsandboxed)(void (^block)(void)) = dlsym(libjailbreak, "run_unsandboxed");

        jbdInitPPLRW();
        run_unsandboxed(^{
            mount("bindfs", argv[2], MNT_RDONLY, argv[1]);
        });

        return 0;
    }
}
