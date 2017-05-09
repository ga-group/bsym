CC ?= cc
CFLAGS ?= -std=c99
WARNFLAGS ?= -Wall -Wextra
YUCK ?= yuck
M4 ?= m4

builddir = .

yuck_CPPFLAGS = -D_POSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700 -D_BSD_SOURCE

all: yuck-bootstrap yuck

clean:
	$(RM) yuck-bootstrap yuck
	$(RM) yuck.yucc yuck.m4i
	$(RM) *.o

yuck-bootstrap: yuck.c
	$(CC) $(CFLAGS) -o $@ -DBOOTSTRAP -g -O3 $(WARNFLAGS) $(yuck_CPPFLAGS) $<

## bootstrapping rules, made for inclusion in your own Makefiles
yuck.m4i: yuck.yuck
	$(MAKE) -$(MAKEFLAGS) yuck-bootstrap
	$(builddir)/yuck-bootstrap $< > $@ \
		|| { rm -f -- $@; false; }

yuck.yucc: yuck.m4 yuck.m4i yuck-coru.h.m4 yuck-coru.c.m4
	$(M4) $^ | \
		tr '\002\003\016\017' '[]()' > $@ \
		|| { rm -f -- $@; false; }

yuck: yuck.c yuck.yucc
	$(CC) $(CFLAGS) -o $@ -g -O3 $(WARNFLAGS) $(yuck_CPPFLAGS) -DYUCK_TEMPLATE_PATH='"$(shell pwd)"' -DYUCK_M4='"$(M4)"' $<
