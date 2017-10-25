CC ?= cc
CFLAGS ?= -std=c99
WARNFLAGS ?= -Wall -Wextra
YUCK ?= ../build-aux/yuck

all: bsym-isin-scrape nquads-explode meld-cfi

clean:
	$(RM) bsym-isin-scrape
	$(RM) nquads-explode
	$(RM) *.o

bsym-isin-scrape: bsym-isin-scrape.c bsym-isin-scrape.yucc
	$(CC) $(CFLAGS) -o $@ -g -O3 $(WARNFLAGS) -D_GNU_SOURCE $(shell curl-config --cflags) $(shell curl-config --libs) $< -DJSMN_PARENT_LINKS jsmn.c jsmn.h

nquads-explode: nquads-explode.c nquads-explode.yucc
	$(CC) $(CFLAGS) -o $@ -g -O3 $(WARNFLAGS) -D_POSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700 -D_BSD_SOURCE $<

meld-cfi: meld-cfi.c meld-cfi.yucc
	$(CC) $(CFLAGS) -o $@ -g -O3 $(WARNFLAGS) -D_POSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700 -D_BSD_SOURCE $<

.SUFFIXES: .yuck .yucc
.yuck.yucc:
	$(YUCK) gen -o $@ $<
