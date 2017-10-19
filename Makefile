LANG = C
LC_ALL = C
SUBDIRS = build-aux/ src/

export

all clean:
	for i in $(SUBDIRS); do \
		(cd "$$i" && $(MAKE) -$(MAKEFLAGS) $@); \
	done

gics.owl.ttl: snippets/gics.owl.h scripts/ttlify-gics-xls.awk
	cat $< > $@
	{ \
		xls2txt archive/GICS\ Structure\ effective\ Sep\ 1,\ 2016.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@@@" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ French.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@fr" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ German.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@de" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Italian.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@it" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Japanese.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@ja" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Korean.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@ko" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Portuguese.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@pt" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Russian.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@ru" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Spanish.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@es" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Simplified\ Chinese.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@zh-Hans" ; \
		xls2txt archive/GICS\ Structure\ 2016\ -\ Traditional\ Sept\ 2016.xls \
		| scripts/ttlify-gics-xls.awk -v "lang=@zh" ; \
	} \
	| sort | uniq \
	| sed 's/"  */"/; s/  *"/"/; s/@[-@a-zA-Z]*"/  "/; s/@@@/@en/' \
	| scripts/statementify.awk \
	>> $@
