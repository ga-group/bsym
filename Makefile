
SUBDIRS = src/

export

all clean:
	for i in $(SUBDIRS); do \
		cd "$$i" && $(MAKE) $@; \
	done
