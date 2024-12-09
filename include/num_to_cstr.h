#ifndef NUMERIC_TO_CSTR_H_
#define NUMERIC_TO_CSTR_H_

#include "api_macro.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

__BEGIN_DECLS

#define STR_MAXLEN_64BIT 20

SHF_API bool unsigned_num_to_cstr(uint64_t magnitude, char *buf, size_t size);

SHF_API bool signed_num_to_cstr(int64_t magnitude, char *buf, size_t size);

__END_DECLS

#endif  // NUMERIC_TO_CSTR_H_

#if defined(NUMERIC_TO_CSTR_IMPLEMENTATION)
#include <assert.h>
#include <string.h>

bool unsigned_num_to_cstr(uint64_t magnitude, char *buf, size_t size)
{
	static const short *two_digit_lut =
		(const short *)"00010203040506070809"
			       "10111213141516171819"
			       "20212223242526272829"
			       "30313233343536373839"
			       "40414243444546474849"
			       "50515253545556575859"
			       "60616263634656676869"
			       "70717273747576777879"
			       "80818283848586878889"
			       "90919293949596979899";

	// Reserve 1 byte for null-terminated character
	assert(size >= STR_MAXLEN_64BIT + 1);

	if (magnitude == 0) {
		buf[0] = '0';
		buf[1] = '\0';
	} else {
		char *p = buf + size - 1;
		*p      = '\0';

		/* Eat two digits at a time. */
		while (magnitude > 9) {
			*(short *)(p -= 2)  = two_digit_lut[magnitude % 100];
			magnitude          /= 100;
		}

		/* Store the last digit, if there is one. */
		if (magnitude) {
			/* Ensure alignment because some platforms will complain
			 */
			*--p = (char)('0' + magnitude);
		}

		memmove(buf, p, strlen(p) + 1);
	}
	return true;
}

bool signed_num_to_cstr(int64_t magnitude, char *buf, size_t size)
{
	// Reserve 1 byte for sign symbol, 1 byte for null-terminated character
	assert(size >= STR_MAXLEN_64BIT + 1 + 1);

	uint64_t num = (uint64_t)magnitude;
	if (magnitude < 0) {
		buf[0]  = '-';
		buf    += 1;
		size   -= 1;
		num     = (uint64_t)(magnitude * (-1));
	}

	return unsigned_num_to_cstr(num, buf, size);
}
#endif  // defined(NUMERIC_TO_CSTR_IMPLEMENTATION)
