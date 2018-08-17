#!/bin/zsh

WD=`dirname "${0}"`/..
NOW=`dconv now`

for i in "${WD}/download-nobackup"/*dif.20*; do
	echo "FILE=`basename ${i} .xz`"
	bsdcat "${i}"
	rm -f -- "${i}"
done \
	| tee >(xz -c > "${WD}/archive/raw_${NOW}.xz") \
	| "${WD}/scripts/ttlify-boff.awk" --diff \
	| tee >(gzip -9 -c > "${WD}/tmp/ttl.d_${NOW}.data.ttl.gz") \
	| ttl-fold --omit-empty /home/freundt/devel/milf/prov/ttlify-boff.prov.ttl \
	| gzip -9 -c > "${WD}/tmp/ttl.d_${NOW}.prov.ttl.gz"
