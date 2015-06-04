//
//  list.c
//  adjacencylist
//
//  Created by Sam Goldman on 6/21/11.
//  Copyright 2011 Sam Goldman. All rights reserved.
//

#include "list.h"
#include <stdlib.h>

Node *node_create(void *data);

List *list_create(node_data_free_callback_t node_data_free_callback) {
    List *list = malloc(sizeof(List));
    list->head = NULL;
    list->count = 0;
    list->node_data_free_callback = node_data_free_callback;
    return list;
}

Node *node_create(void *data) {
    Node *node = malloc(sizeof(Node));
    node->data = data;
    node->next = NULL;
    return node;
}

void list_add_data(List *list, void *data) {
    Node *node = node_create(data);
    node->next = list->head;
    list->head = node;
    list->count++;
}

void list_add_data_sorted(List *list, void *data, int (*cmp)(const void *a, const void *b)) {
    Node *node = node_create(data);
    Node *n = list->head;
    Node *prev_n = NULL;
    while (n && cmp(n->data, data) < 0) {
        prev_n = n;
        n = n->next;
    }
    node->next = n;
    if (!prev_n) {
        list->head = node;
    }
    else {
        prev_n->next = node;
    }
    list->count++;
}

void list_remove_data(List *list, void *data) {
    Node *n = list->head;
    Node *prev_n = NULL;
    while (n) {
        if (n->data == data) {
            if (!prev_n) {
                list->head = n->next;
            }
            else {
                prev_n->next = n->next;
            }
            list->node_data_free_callback(data);
            list->count--;
            free(n);
            break;
        }
        prev_n = n;
        n = n->next;
    }
}

void list_free(List *list) {
    Node *n = list->head;
    while (n) {
        Node *next_n = n->next;
        list->node_data_free_callback(n->data);
        free(n);
        n = next_n;
    }
    free (list);
}

void list_sort(List *list, int(*cmp)(const void *a, const void *b)) {
    Node *p, *q, *e, *head, *tail;
    int insize, nmerges, psize, qsize, i;
    
    if (!list || !list->head)
        return;
    
    head = list->head;
    
    insize = 1;
    
    while (1) {
        p = head;
        head = NULL;
        tail = NULL;
        
        nmerges = 0;
        
        while (p) {
            nmerges++;
            q = p;
            psize = 0;
            for (i = 0; i < insize; i++) {
                psize++;
                q = q->next;
                if (!q) break;
            }
            qsize = insize;
            while (psize > 0 || (qsize > 0 && q)) {
                if (psize == 0) {
                    e = q; q = q->next; qsize--;
                }
                else if (qsize == 0 || !q) {
                    e = p; p = p->next; psize--;
                }
                else if (cmp(p->data, q->data) <= 0) {
                    e = p; p = p->next; psize--;
                }
                else {
                    e = q; q = q->next; qsize--;
                }
                
                if (tail) {
                    tail->next = e;
                }
                else {
                    head = e;
                }
                
                tail = e;
            }
            p = q;
        }
        tail->next = NULL;
        
        if (nmerges <= 1) {
            list->head = head;
            return;
        }
        
        insize *= 2;
    }
}
