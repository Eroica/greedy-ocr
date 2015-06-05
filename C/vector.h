#ifndef VECTOR_H
#define VECTOR_H

#ifndef VECTOR_INIT_CAPACITY
#define VECTOR_INIT_CAPACITY 10
#endif

#ifndef ERR_INVALID_ARGUMENT
#define ERR_INVALID_ARGUMENT        -1
#endif
#ifndef ERR_INSUFFICIENT_RESOURCE
#define ERR_INSUFFICIENT_RESOURCE   -2
#endif

typedef struct {
    void **data;
    int size;
    int capacity;
}vector;

int vector_init(vector *v);
int vector_push_back(vector *v, void *elm);
int vector_get_size(vector *v);
void *vector_get_head(vector *v);
void *vector_pop_head(vector *v);
void *vector_get(vector *v, int idx);
void *vector_pop_back(vector *v);
int vector_remove(vector *v, int idx);
void vector_destroy(vector *v);

#endif
