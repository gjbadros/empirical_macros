/*  ###############################################################
    ##
    ##     File:         heap.h
    ##
    ##     Programmer:   Shawn Flisakowski
    ##     Date:         Apr 27, 1994
    ## 
    ##     Multi-Heap Manager
    ##
    ###############################################################  */

#ifndef    HEAP_H
#define    HEAP_H

#include "utype.h"

/*  ###############################################################  */

#define    MIN_HUNK_ARRY        8
#define    DEFLT_RATIO        256

#define    PNTR_SZE             4
#define    MIN_SIZE      PNTR_SZE
#define    ALGN_SZE             4

/*  ###############################################################  */

#define    min(X, Y)        ( ((X) < (Y)) ? (X) : (Y) )
#define    max(X, Y)        ( ((X) > (Y)) ? (X) : (Y) )

/*  ###############################################################  */

typedef    struct  hp_strt {

    uint    chnk_sze;
    uint    ch_ratio;

    uint    num_alloc;
    uint    num_free;
    uint    num_hunks;

    uint    hunk_array_sze;
    uint    next_chunk;

    void   *free_list;
    void  **hunks;

} Heap;

#define    HEAP_SZE    sizeof(Heap)

/*  ###############################################################  */

Heap *CreateHeap( uint chunk_size, uint chnk_hunk_ratio );

void  HeapInfo( Heap *heap, uint *allocd, uint *freed, uint *hunks );

void  DestroyHeap( Heap *heap );

void  FreeHeap( Heap *heap );

void *HeapErr( int fail );

void *HeapAlloc_Gen( Heap *heap, int fail );

void *HeapAlloc2( Heap *heap );

void *HeapAlloc( Heap *heap );

void  HeapFree( Heap *heap, void *chunk );

/*  ###############################################################  */

#endif    /* HEAP_H  */
