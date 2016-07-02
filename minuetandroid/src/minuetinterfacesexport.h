
#ifndef MINUETINTERFACES_EXPORT_H
#define MINUETINTERFACES_EXPORT_H

#ifdef MINUETINTERFACES_STATIC_DEFINE
#  define MINUETINTERFACES_EXPORT
#  define MINUETINTERFACES_NO_EXPORT
#else
#  ifndef MINUETINTERFACES_EXPORT
#    ifdef minuetinterfaces_EXPORTS
        /* We are building this library */
#      define MINUETINTERFACES_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define MINUETINTERFACES_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef MINUETINTERFACES_NO_EXPORT
#    define MINUETINTERFACES_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef MINUETINTERFACES_DEPRECATED
#  define MINUETINTERFACES_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef MINUETINTERFACES_DEPRECATED_EXPORT
#  define MINUETINTERFACES_DEPRECATED_EXPORT MINUETINTERFACES_EXPORT MINUETINTERFACES_DEPRECATED
#endif

#ifndef MINUETINTERFACES_DEPRECATED_NO_EXPORT
#  define MINUETINTERFACES_DEPRECATED_NO_EXPORT MINUETINTERFACES_NO_EXPORT MINUETINTERFACES_DEPRECATED
#endif

#define DEFINE_NO_DEPRECATED 0
#if DEFINE_NO_DEPRECATED
# define MINUETINTERFACES_NO_DEPRECATED
#endif

#endif
