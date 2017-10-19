LANG = C
LC_ALL = C
SUBDIRS = build-aux/ src/

export

all clean:
	for i in $(SUBDIRS); do \
		(cd "$$i" && $(MAKE) -$(MAKEFLAGS) $@); \
	done

gics.ttl: scripts/ttlify-gics-xls.awk
	{ \
		xls2txt archive/GICS\ Structure\ effective\ Sep\ 1,\ 2016.xls \
		| $< -v "lang=@en" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ French.xls \
		| $< -v "lang=@fr" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ German.xls \
		| $< -v "lang=@de" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Italian.xls \
		| $< -v "lang=@it" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Japanese.xls \
		| $< -v "lang=@ja" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Korean.xls \
		| $< -v "lang=@ko" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Portuguese.xls \
		| $< -v "lang=@pt" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Russian.xls \
		| $< -v "lang=@ru" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Spanish.xls \
		| $< -v "lang=@es" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Simplified\ Chinese.xls \
		| $< -v "lang=@zh-Hans" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Traditional\ Sept\ 2016.xls \
		| $< -v "lang=@zh" ; \
	} \
	| sort | uniq \
	> $@
