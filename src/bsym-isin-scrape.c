#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <curl/curl.h>
#include <assert.h>
#include "jsmn.h"

#define BASE	"http://bsym.bloomberg.com/sym/"
#define SESS	"dwr/call/plaincall/__System.pageLoaded.dwr"
#define SRCH	"dwr/call/plaincall/searchMgr.search.dwr"

#define strlenof(x)	(sizeof(x) - 1U/*\nul*/)
#define countof(x)	(sizeof(x) / sizeof(*x))

struct ctx_s {
	const char *sid;
	unsigned int iitem;
	unsigned int nitem;
	char *buf;
	size_t bix;
	size_t bsz;
	CURL *hdl;
	char *sessid;
	size_t sessid_len;
};

static char *agent = "Mozilla/5.0 (compatible; bsym-scrape/0.1)";

static size_t
sess_cb(void *data, size_t size, size_t nmemb, void *clo)
{
	static char sid[32U];
	size_t rz = size * nmemb;
	char *const ep = (char*)data + rz;
	char *sp;
#define SESS_DIRECTIVE	"handleNewScriptSession"
	struct ctx_s *ctx = clo;
 
	if ((sp = memmem(data, rz, SESS_DIRECTIVE, strlenof(SESS_DIRECTIVE)))) {
		/* found it, go behind first quote */
		char *tp;

		while (sp < ep && *sp++ != '"');
		for (tp = sp; tp < ep && *tp != '"'; tp++);

		if (tp - sp <= sizeof(sid)) {
			memcpy(sid, sp, tp - sp);
			ctx->sessid = sid;
			ctx->sessid_len = tp - sp;
		}
	}
	/* consume everything */
	return rz;
}

static int
get_sess(struct ctx_s ctx[static 1U])
{
static const char sess[] = "\
callCount=1\n\
windowName=\n\
c0-scriptName=__System\n\
c0-methodName=pageLoaded\n\
c0-id=0\n\
batchId=0\n\
page=%2Fsym%2F\n\
httpSessionId=\n\
scriptSessionId=\n\
";
	CURLcode res;
	int rc = 0;

	curl_easy_setopt(ctx->hdl, CURLOPT_URL, BASE SESS);
	curl_easy_setopt(ctx->hdl, CURLOPT_USERAGENT, agent);
	curl_easy_setopt(ctx->hdl, CURLOPT_WRITEFUNCTION, sess_cb);
	curl_easy_setopt(ctx->hdl, CURLOPT_WRITEDATA, ctx);
	curl_easy_setopt(ctx->hdl, CURLOPT_POSTFIELDS, sess);
	curl_easy_setopt(ctx->hdl, CURLOPT_POSTFIELDSIZE, strlenof(sess));

	if ((res = curl_easy_perform(ctx->hdl)) != CURLE_OK) {
		fprintf(stderr, "curl_easy_perform() failed: %s\n",
			curl_easy_strerror(res));
		rc = -1;
	} else if (ctx->sessid == NULL) {
		rc = -1;
	}

	curl_easy_reset(ctx->hdl);
	return rc;
}

static size_t
recv_cb(void *data, size_t size, size_t nmemb, void *clo)
{
	size_t rz = size * nmemb;
	struct ctx_s *ctx = clo;
	const char *sp;
	const char *ep;
#define BODATA	"handleCallback("
#define EODATA	");"

	/* try and find our beacons */
	if ((sp = memmem(data, rz, BODATA, strlenof(BODATA))) == NULL) {
		/* didn't find it, better copy it all */
		sp = data;

		if (ctx->bix == 0U) {
			/* no need, is there? */
			return rz;
		}
	} else {
		/* reset buffer index */
		ctx->bix = 0U;
		/* fast-forward to actual data `(' */
		for (const char *const tp = (char*)data + rz;
		     sp < tp && *sp != '{'; sp++);
	}
	if ((ep = memmem(data, rz, EODATA, strlenof(EODATA))) == NULL) {
		/* just copy it all */
		ep = (char*)data + rz;
	} else {
		/* rewind to last `}' */
		for (; ep > data && ep[-1] != '}'; ep--);
	}

	assert(ep >= sp);

	/* resize? */
	if (ctx->bix + (ep - sp) > ctx->bsz) {
		ctx->buf = realloc(ctx->buf, ctx->bsz *= 2U);
	}

	/* copy */
	memcpy(ctx->buf + ctx->bix, sp, ep - sp);
	ctx->bix += ep - sp;
	return rz;
}

static int
fetch1(struct ctx_s ctx[static 1U])
{
	static unsigned int bid;
	static char _url[1024U];
	CURLcode res;
	int rc = 0;
	int uz;

	curl_easy_setopt(ctx->hdl, CURLOPT_URL, BASE SRCH);
	curl_easy_setopt(ctx->hdl, CURLOPT_USERAGENT, agent);
	curl_easy_setopt(ctx->hdl, CURLOPT_WRITEFUNCTION, recv_cb);
	curl_easy_setopt(ctx->hdl, CURLOPT_WRITEDATA, ctx);

	uz = snprintf(_url, sizeof(_url), "\
callCount=1\n\
windowName=\n\
c0-scriptName=searchMgr\n\
c0-methodName=search\n\
c0-id=0\n\
c0-e1=string:%s\n\
c0-e2=string:\n\
c0-e3=number:100\n\
c0-e4=number:%u\n\
c0-e5=boolean:true\n\
c0-param0=Object_SearchCriteria:{search:reference:c0-e1, filter:reference:c0-e2, limit:reference:c0-e3, start:reference:c0-e4, allSources:reference:c0-e5}\n\
batchId=%u\n\
page=%%2Fsym%%2F\n\
httpSessionId=\n\
scriptSessionId=%.*s\n\
", ctx->sid, ctx->iitem, ++bid, (int)(ctx->sessid_len), ctx->sessid);

	curl_easy_setopt(ctx->hdl, CURLOPT_POSTFIELDS, _url);
	curl_easy_setopt(ctx->hdl, CURLOPT_POSTFIELDSIZE, uz);

	if ((res = curl_easy_perform(ctx->hdl)) != CURLE_OK) {
		fprintf(stderr, "curl_easy_perform() failed: %s\n",
			curl_easy_strerror(res));
		rc = -1;
	}

	curl_easy_reset(ctx->hdl);
	return rc;
}

static size_t
tokcpy(char *restrict buf, const char *src, jsmntok_t tok)
{
	const char *cp = src + tok.start;
	size_t cz = tok.end - tok.start;
	char *restrict xp;

	if (!memchr(cp, '\\', cz)) {
		memcpy(buf, cp, cz);
		return cz;
	}
	/* otherwise de-escape */
	for (xp = buf; cz; cz--, xp++) {
		if ((*xp = *cp++) == '\\') {
			if (!--cz) {
				break;
			}
			switch (*cp++) {
			default:
				*xp = cp[-1];
				break;

			case 'b':
				*xp = '\b';
				break;
			case 'f':
				*xp = '\f';
				break;
			case 'r':
				*xp = '\r';
				break;
			case 'n':
				*xp = '\n';
				break;
			case 't':
				/* degrade to space */
				*xp = ' ';
				break;
			}
		}
	}
	return xp - buf;
}

static int
print_data(struct ctx_s ctx[static 1U], jsmntok_t *tok, size_t ntok)
{
#define XBBGID	"ID135"
#define XBBCID	"ID145"
#define XTICKR	"DY003"
#define XBPSRC	"DX282"
#define XSECTR	"DS122"
#define XSTYPE	"DS213"
#define XSNAME	"DS002"
	enum {
		BBGID,
		BBCID,
		TICKR,
		BPSRC,
		SECTR,
		STYPE,
		SNAME,
		NTOKEN
	};
	INDEX_T offs[NTOKEN] = {0U};
	static char buf[4096U];
	size_t bix = 0U;

	for (INDEX_T i = 0U; i < ntok; i += 2U) {
		const char *cp = ctx->buf + tok[i].start;
		const size_t cz = tok[i].end - tok[i].start;

		if (cz != 5U) {
			;
		} else if (!memcmp(cp, XBBGID, 5U)) {
			offs[BBGID] = i + 1U;
		} else if (!memcmp(cp, XBBCID, 5U)) {
			offs[BBCID] = i + 1U;
		} else if (!memcmp(cp, XTICKR, 5U)) {
			offs[TICKR] = i + 1U;
		} else if (!memcmp(cp, XBPSRC, 5U)) {
			offs[BPSRC] = i + 1U;
		} else if (!memcmp(cp, XSECTR, 5U)) {
			offs[SECTR] = i + 1U;
		} else if (!memcmp(cp, XSTYPE, 5U)) {
			offs[STYPE] = i + 1U;
		} else if (!memcmp(cp, XSNAME, 5U)) {
			offs[SNAME] = i + 1U;
		}
	}

	/* build up the output line */
	bix = strlen(ctx->sid);
	memcpy(buf, ctx->sid, bix);

	for (size_t j = 0U; j < NTOKEN; j++) {
		const size_t i = offs[j];

		buf[bix++] = '\t';
		bix += tokcpy(buf + bix, ctx->buf, tok[i]);
	}

	buf[bix++] = '\n';
	fwrite(buf, sizeof(*buf), bix, stdout);
	return 0;
}

static int
print1(struct ctx_s ctx[static 1U])
{
	static jsmntok_t tok[2048U];
	jsmn_parser p;
	INDEX_T i = 2U;
	int r;

	jsmn_init(&p);
	if ((r = jsmn_parse(&p, ctx->buf, ctx->bix, tok, countof(tok))) < 0) {
		goto invalid;
	} else if (tok[0U].type != JSMN_OBJECT) {
		/* naughth token should indicate an object */
		goto invalid;
	}

	{
		const char *cp = ctx->buf + tok[1U].start;
		const size_t cz = tok[1U].end - tok[1U].start;

		if (cz != 4U) {
			goto invalid;
		} else if (!memcmp(cp, "data", 4U)) {
			goto data_first;
		} else if (!memcmp(cp, "size", 4U)) {
			goto size_first;
		} else {
			goto invalid;
		}
	}

size_first:
	ctx->nitem = strtoul(ctx->buf + tok[i++].start, NULL, 10);
	{
		const char *cp = ctx->buf + tok[i].start;
		const size_t cz = tok[i].end - tok[i].start;

		if (cz != 4U || memcmp(cp, "data", 4U)) {
			goto invalid;
		}
		/* fast-forward to data value */
		i++;
	}
data_first:
	if (tok[i].type != JSMN_ARRAY) {
		goto invalid;
	}
	for (size_t ni = tok[i++].size, j = 0U; j < ni && i < (INDEX_T)r; j++) {
		if (tok[i].type != JSMN_OBJECT) {
			/* we expect objects here */
			break;
		}
		print_data(ctx, tok + i + 1U, 2U * tok[i].size);
		i += 1U + 2U * tok[i].size;
		ctx->iitem++;
	}
	if (i < (INDEX_T)r && !ctx->nitem) {
		const char *cp = ctx->buf + tok[i].start;
		const size_t cz = tok[i].end - tok[i].start;

		if (cz == 4U && !memcmp(cp, "size", 4U)) {
			/* fast-forward to size value */
			i++;
			ctx->nitem = strtoul(ctx->buf + tok[i].start, NULL, 10);
		}
	}
	return 0;

invalid:
	fprintf(stderr, "invalid json data %d\n", r);
	fwrite(ctx->buf, sizeof(*ctx->buf), ctx->bix, stderr);
	fputc('\n', stderr);
	return -1;
}

static int
repl(struct ctx_s ctx[static 1U], const char *sid)
{
	ctx->iitem = ctx->nitem = 0U;
	ctx->sid = sid;

	do {
		if (fetch1(ctx) < 0) {
			return 1;
		} else if (print1(ctx) < 0) {
			return 1;
		}
	} while (ctx->iitem < ctx->nitem);
	return 0;
}


#include "bsym-isin-scrape.yucc"

int
main(int argc, char *argv[])
{
	yuck_t argi[1U];
	size_t i;
	int rc = 0;
	struct ctx_s ctx[1U];

	if (yuck_parse(argi, argc, argv) < 0) {
		rc = 1;
		goto out;
	} else if ((ctx->hdl = curl_easy_init()) == NULL) {
		rc = 1;
		goto out;
	}

	if (argi->agent_arg) {
		agent = argi->agent_arg;
	}

	/* get ourself a session id */
	if (get_sess(ctx) < 0) {
		fputs("Error: could not obtain session id\n", stderr);
	}

	/* set up the result buffer */
	if ((ctx->bix = 0U, ctx->buf = malloc(ctx->bsz = 4096U)) == NULL) {
		fputs("Error: cannot allocate buffer\n", stderr);
		goto bork;
	}

	if (!argi->nargs) {
		char *line = NULL;
		size_t llen = 0U;
		ssize_t nrd;

		while ((nrd = getline(&line, &llen, stdin)) > 0) {
			if (line[nrd - 1] == '\n') {
				line[--nrd] = '\0';
			}
			if (nrd > 0 && line[nrd - 1] == '\r') {
				line[--nrd] = '\0';
			}
			rc |= repl(ctx, line);
		}
		free(line);
	}
	for (i = 0U; i < argi->nargs; i++) {
		rc |= repl(ctx, argi->args[i]);
	}

bork:
	curl_easy_cleanup(ctx->hdl);
out:
	yuck_free(argi);
	return rc;
}
