
SUBDIRS = build-aux/ src/

export

all clean:
	for i in $(SUBDIRS); do \
		(cd "$$i" && $(MAKE) -$(MAKEFLAGS) $@); \
	done
