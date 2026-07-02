// Minimal malloc stub for bare-metal environment
// libgcc's emutls requires malloc/free but they're never actually called
// in this single-threaded bare-metal context
#include <stddef.h>

extern char _end[];
static char *heap_ptr = 0;

void *malloc(size_t size) {
    if (!heap_ptr) heap_ptr = _end;
    void *p = heap_ptr;
    heap_ptr += (size + 7) & ~7; // align to 8 bytes
    return p;
}

void free(void *p) {
    (void)p;
}

void *calloc(size_t n, size_t size) {
    size_t total = n * size;
    char *p = malloc(total);
    for (size_t i = 0; i < total; i++) p[i] = 0;
    return p;
}

void *realloc(void *p, size_t size) {
    (void)p;
    return malloc(size);
}
