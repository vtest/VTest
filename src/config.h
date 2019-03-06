
#define HAVE_CLOCK_GETTIME 1
#define HAVE_NANOSLEEP 1

#ifdef __linux__
#  define _GNU_SOURCE 1
#  define HAVE_SYS_VFS_H 1
#  define HAVE_FALLOCATE 1
#else
#  define HAVE_STATVFS_H 1
#  define HAVE_SYS_MOUNT_H 1
#endif

#ifdef __FreeBSD__
#  define HAVE_CLOSEFROM 1
#endif
