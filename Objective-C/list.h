//
//  list.h
//  adjacencylist
//
//  Created by Sam Goldman on 6/21/11.
//  Copyright 2011 Sam Goldman. All rights reserved.
//

typedef void (*node_data_free_callback_t)(void *);

typedef struct Node {
    void *data;
    struct Node *next;
} Node;

typedef struct List {
    Node *head;
    int count;
    node_data_free_callback_t node_data_free_callback;
} List;

List *list_create(node_data_free_callback_t node_data_free_callback);
void list_add_data(List *list, void *data);
void list_add_data_sorted(List *list, void *data, int (*cmp)(const void *a, const void *b));
void list_remove_data(List *list, void *data);
void list_free(List *list);
void list_sort(List *list, int(*cmp)(const void *a, const void *b));
