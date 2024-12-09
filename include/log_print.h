#ifndef LOG_PRINT_H_
#define LOG_PRINT_H_

#include <stdio.h>
#include <sys/cdefs.h>

__BEGIN_DECLS

#define LOG_PRINT(fp, format, args...) fprintf(fp, format "\n", ##args)

#define LOG_INFO(format, args...)  LOG_PRINT(stdout, format, ##args)
#define LOG_ERROR(format, args...) LOG_PRINT(stderr, format, ##args)

#ifdef NDEBUG
	#define LOG_DEBUG(format, args...)
	#define LOG_DEBUG_NOLN(format, args...)
#else
	#define LOG_DEBUG(format, args...)      LOG_PRINT(stdout, format, ##args)
	#define LOG_DEBUG_NOLN(format, args...) fprintf(stdout, format, ##args)
#endif

__END_DECLS

#endif  // LOG_PRINT_H_
