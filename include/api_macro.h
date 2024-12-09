#ifndef API_MACRO_H_
#define API_MACRO_H_

#include <sys/cdefs.h>

__BEGIN_DECLS

#if defined(_WIN32) || defined(__CYGWIN__)
	#define SHF_HELPER_DLL_IMPORT __declspec(dllimport)
	#define SHF_HELPER_DLL_EXPORT __declspec(dllexport)
	#define SHF_HELPER_DLL_LOCAL
#else
	#if defined(__GNUC__) && __GNUC__ >= 4
		#define SHF_HELPER_DLL_IMPORT \
			__attribute__((visibility("default")))
		#define SHF_HELPER_DLL_EXPORT \
			__attribute__((visibility("default")))
		#define SHF_HELPER_DLL_LOCAL \
			__attribute__((visibility("hidden")))
	#else
		#define SHF_HELPER_DLL_IMPORT
		#define SHF_HELPER_DLL_EXPORT
		#define SHF_HELPER_DLL_LOCAL
	#endif
#endif

#if defined(SHF_DLL)
	#if defined(SHF_DLL_EXPORTS)
		#define SHF_API SHF_HELPER_DLL_EXPORT
	#else
		#define SHF_API SHF_HELPER_DLL_IMPORT
	#endif
	#define SHF_LOCAL SHF_HELPER_DLL_LOCAL
#else
	#define SHF_API
	#define SHF_LOCAL
#endif

__END_DECLS

#endif  // API_MACRO_H_
