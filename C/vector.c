#include <stdlib.h>
#include "vector.h"

int vector_init(vector *v)
{
    if(!v)
    {
        return ERR_INVALID_ARGUMENT;
    }
    if(NULL == (v->data = malloc(sizeof(void*)*VECTOR_INIT_CAPACITY)))
    {
        return ERR_INSUFFICIENT_RESOURCE;
    }
    v->size = 0;
    v->capacity = 10;
    return 0;
}

int vector_push_back(vector *v, void *elm)
{
    if(!v)
    {
        return ERR_INVALID_ARGUMENT;
    }
    if( v->size+1 > v->capacity)
    {
        v->capacity *= 2;
        if(NULL == (v->data = realloc(v->data,sizeof(void*) * v->capacity)))
        {
            return ERR_INSUFFICIENT_RESOURCE;
        }
    }
    v->data[v->size++] = elm;
    return 0;
}

int vector_get_size(vector *v)
{
    if(!v)
    {
        return ERR_INVALID_ARGUMENT;
    }
    return v->size;
}
void *vector_get_head(vector *v)
{
    if(!v || v->size == 0)
    {
        return NULL;
    }
    return v->data[0];
}

void *vector_get(vector *v, int idx)
{
    if(!v || idx < 0)
    {
        return NULL;
    }
    if(idx >= v->size)
    {
        return NULL;
    }
    return v->data[idx];
}

void *vector_pop_back(vector *v)
{
    if(!v || v->size == 0)
    {
        return NULL;
    }
    v->size--;
    return v->data[v->size+1];
}

int vector_remove(vector *v, int idx)
{
    int i;
    if(!v || idx < 0 )
    {
        return ERR_INVALID_ARGUMENT;
    }
    if(idx >= v->size)
    {
        return ERR_INVALID_ARGUMENT;
    }
    v->size--;
    for(i=idx; i<v->size; i++)
    {
        v->data[i] = v->data[i+1];
    }
    return 0;
}

void *vector_pop_head(vector *v)
{
    void *rv;
    if(!v || v->size == 0)
    {
        return NULL;
    }
    rv = vector_get_head(v);
    vector_remove(v,0);
    return rv;
}

void vector_destroy(vector *v)
{
    if(v)
    {
        free(v->data);
        v->size = 0;
        v->capacity = -1;
    }
}
