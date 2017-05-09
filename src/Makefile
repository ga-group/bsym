CC ?= cc
CFLAGS ?= -std=c99
WARNFLAGS ?= -Wall -Wextra
YUCK ?= ../build-aux/yuck

all: bsym-isin-scrape

clean:
	$(RM) bsym-isin-scrape
	$(RM) *.o

bsym-isin-scrape.yucc: bsym-isin-scrape.yuck
	$(YUCK) gen -o $@ $<

bsym-isin-scrape: bsym-isin-scrape.c bsym-isin-scrape.yucc
	$(CC) $(CFLAGS) -o $@ -g -O3 $(WARNFLAGS) -D_GNU_SOURCE $(shell curl-config --cflags) $(shell curl-config --libs) $< -DJSMN_PARENT_LINKS jsmn.c jsmn.h
