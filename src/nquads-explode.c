/*** nquads-explode.c -- nq file exploder
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


static char prfx[1024U];
static size_t prfz;

static size_t
mtrcpy(char *restrict tgt, const char *src, size_t len)
{
/* copy up to LEN character from SRC to TGT replacing charcters
 * we don't want in filenames by underscores */
	size_t j = 0U;

	for (size_t i = 0U; i < len; i++) {
		char c = src[i] != '/' &&
			(src[i] >= ',' && src[i] <= '9' ||
			 src[i] >= 'A' && src[i] <= 'Z' ||
			 src[i] >= 'a' && src[i] <= 'z')
			? src[i] : '_';
		tgt[j] = c;
		j += j || c != '_';
	}
	/* trim trailing underscores */
	for (; j > 0U && tgt[j - 1U] == '_'; j--);
	return j;
}

static ssize_t
mkfn(const char *line, size_t llen)
{
	const char *fp, *ep;
	size_t n;

	if (UNLIKELY(!llen)) {
		return -1;
	}
	/* find the last <...> */
	for (ep = line + llen - 1; ep >= line && *ep != '>'; ep--);
	for (fp = ep - 1; fp > line && fp[-1] != '<'; fp--);

	if (UNLIKELY(fp <= line || ep <= line)) {
		return -1;
	} else if (UNLIKELY(ep - fp >= countof(prfx))) {
		ep = fp + countof(prfx) - 1;
	}

	/* assume URNs and fast-forward past : or :// */
	for (const char *x = memchr(fp, ':', ep - fp); x;) {
		fp = x + 1U;
		break;
	}
	/* otherwise copy to PRFX */
	if (UNLIKELY(!(n = mtrcpy(prfx + prfz, fp, ep - fp)))) {
		return -1;
	}
	/* append .nq */
	prfx[prfz + n++] = '.';
	prfx[prfz + n++] = 'n';
	prfx[prfz + n++] = 'q';

	prfx[prfz + n + 0U] = '\0';
	return n;
}

static int
explode(FILE *whence)
{
#define NMRU	(16U)
	static size_t tick;
	/* cache of most recently used filenames */
	static char last[countof(prfx)][NMRU];
	static size_t when[NMRU];
	static int fd[NMRU];
	size_t fnaz;
	char *line = NULL;
	size_t llen = 0;
	ssize_t nrd;

	while ((nrd = getline(&line, &llen, whence)) >= 0) {
		const int ofl = O_RDWR | O_APPEND | O_CREAT;
		ssize_t nfn;
		size_t which;

		if (UNLIKELY((nfn = mkfn(line, nrd)) < 0)) {
			errno = 0, error("cannot deduce filename from quad");
			continue;
		}

		/* see if we've got this one */
		for (which = 0U; which < NMRU; which++) {
			if (!memcmp(last[which], prfx, nfn + 1U/*\nul*/)) {
				goto wr;
			}
		}
		/* otherwise see where we can put him */
		for (size_t i = 0U, least = ++tick; i < NMRU; i++) {
			if (when[i] < least) {
				least = when[i];
				which = i;
			}
		}
		/* one of them will be minimal */
		if (LIKELY(when[which])) {
			/* close the one before */
			close(fd[which]);
		}
		if (UNLIKELY((fd[which] = open(prfx, ofl, 0644)) < 0)) {
			/* oh no */
			error("cannot open file `%s'", prfx);
			when[which] = 0U;
			memset(last[which], 0, countof(prfx));
			continue;
		}
		/* make sure we know when this was last used */
		when[which] = tick;
		/* and obviously remember the filename too */
		memcpy(last[which], prfx, nfn + 1U);
		/* output current file name for educational purposes */
		fwrite(prfx, sizeof(*prfx), nfn, stdout);

	wr:
		/* bang the line */
		write(fd[which], line, nrd);
	}

	/* leave no files open */
	for (size_t i = 0U; i < NMRU; i++) {
		close(fd[i]);
	}
	memset(last, 0, sizeof(last));
	memset(when, 0, sizeof(when));

	/* free the resources */
	free(line);
	return 0;
}


#include "nquads-explode.yucc"

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

	/* put prefix into local vars */
	if (argi->prefix_arg) {
		prfz = strlen(argi->prefix_arg);
		memcpy(prfx, argi->prefix_arg, prfz);
	}

	if (argi->nargs) {
		/* go over them files */
		for (size_t i = 0; i < argi->nargs; i++) {
			FILE *fp;

			if ((fp = fopen(argi->args[i], "r")) != NULL) {
				explode(fp);
				fclose(fp);
			}
		}
	} else {
		/* aah, stdin */
		rc = explode(stdin);
	}

out:
	yuck_free(argi);
	return rc;
}

/* nquads-explode.c ends here */
