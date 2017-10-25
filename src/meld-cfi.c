/*** meld-cfi.c -- helper script for combinatorial cfi classes
 *
 * Copyright (C) 2016-2017 Sebastian Freundt
 *
 * Author:  Sebastian Freundt <freundt@ga-group.nl>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the author nor the names of any contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ***/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdarg.h>
#include <errno.h>

#if !defined LIKELY
# define LIKELY(_x)	__builtin_expect((_x), 1)
#endif	/* !LIKELY */
#if !defined UNLIKELY
# define UNLIKELY(_x)	__builtin_expect((_x), 0)
#endif	/* UNLIKELY */
#if !defined countof
# define countof(x)	(sizeof(x) / sizeof(*x))
#endif	/* !countof */

static __attribute__((format(printf, 1, 2))) void
error(const char *fmt, ...)
{
	va_list vap;
	va_start(vap, fmt);
	vfprintf(stderr, fmt, vap);
	va_end(vap);
	if (errno) {
		fputc(':', stderr);
		fputc(' ', stderr);
		fputs(strerror(errno), stderr);
	}
	fputc('\n', stderr);
	return;
}


static int
meld_them(void)
{
	char *line = NULL;
	size_t llen = 0U;
	signed char cfi[] = "\
cfi:XXXXXX\n\
  a owl:Class ;\n\
  rdfs:subClassOf ";

	for (ssize_t nrd; (nrd = getline(&line, &llen, stdin)) > 0;) {
		size_t n, m;

		for (n = 1U; line[11U * n - 1U] == '\t'; n++);
		for (m = 1U; m < n && !memcmp(line, line + 11U * m, 6U); m++);
		if (m < n) {
			/* don't bother */
			continue;
		}

		memcpy(cfi, line, 10U);
		for (size_t j = 1U; j < n; j++) {
			for (size_t i = 0U; i < 10U; i++) {
				cfi[i] = cfi[i] != 'X'
					? cfi[i] : line[11U * j + i];
			}
		}
		for (size_t i = 0U; i < 10U; i++) {
			cfi[i] = (cfi[i] >= ' ') ? cfi[i] : '?';
		}
		fwrite(cfi, 1, sizeof(cfi) - 1U, stdout);
		fwrite(line, 1, 10U, stdout);
		for (size_t j = 1U; j < n; j++) {
			fwrite(" , ", 1, 3U, stdout);
			fwrite(line + 11U * j, 1, 10U, stdout);
		}
		fputc(' ', stdout);
		fputc('.', stdout);
		fputc('\n', stdout);
		fputc('\n', stdout);
	}
	free(line);
	return 0;
}


#include "meld-cfi.yucc"

int
main(int argc, char *argv[])
{
	yuck_t argi[1U];
	int rc = 0;

	/* parse the command line */
	if (yuck_parse(argi, argc, argv)) {
		rc = 1;
		goto out;
	}

	rc = meld_them() < 0;

out:
	yuck_free(argi);
	return rc;
}

/* meld-cfi.c ends here */
