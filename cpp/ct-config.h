/**************************************************************************/
/*    config.h                                                            */
/**************************************************************************/

#ifndef CONFIG_H
#define CONFIG_H

/**************************************************************************/

#ifdef __cplusplus
#    define CPLUS
#    define EXTERN extern "C"
#else
#    define EXTERN extern
#endif

/**************************************************************************/
/*
    The following macro helps define argument lists for fns: the arg lists are
    eaten up when not allowed (as in C).  e.g. extern int foo ARGS((int, int));
*/

#if defined(__STDC__) || defined(__cplusplus)
#    define ARGS(args) args
#else
#    define ARGS(args) ()
#endif

/**************************************************************************/

#endif CONFIG_H
