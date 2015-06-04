//
//  graph.h
//  adjacencylist
//
//  Created by Sam Goldman on 6/21/11.
//  Copyright 2011 Sam Goldman. All rights reserved.
//

#include <stdbool.h>
#include "list.h"

typedef struct Edge {
    struct Vertex *vertex;
    double weight;
} Edge;

typedef struct Vertex {
    void *data;
    struct List *edges;
    int indegree;
    int outdegree;
} Vertex;

typedef struct Graph {
    struct List *vertices;
} Graph;

Graph *graph_create(void);
Vertex *vertex_create(void *data);
Edge *edge_create(Vertex *vertex, double weight);

void graph_add_vertex(Graph *graph, Vertex *vertex);
void graph_add_vertex_sorted(Graph *graph, Vertex *vertex, int(*cmp)(const void *a, const void *b));
void graph_remove_vertex(Graph *graph, Vertex *vertex);

void vertex_add_edge(Vertex *vertex, Edge *edge);
void vertex_add_edge_sorted(Vertex *vertex, Edge *edge);
void vertex_remove_edge(Vertex *vertex, Edge *edge);

void vertex_add_edge_to_vertex(Vertex *from, Vertex *to, double weight);
void vertex_add_edge_to_vertex_sorted(Vertex *from, Vertex *to, double weight);
void vertex_remove_edge_to_vertex(Vertex *from, Vertex *to);

void graph_sort_vertices(Graph *graph, int(*cmp)(const void *a, const void *b));
void vertex_sort_edges(Vertex *vertex);

bool graph_is_balanced(Graph *graph);

void graph_free(Graph *graph);
