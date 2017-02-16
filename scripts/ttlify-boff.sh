#!/bin/zsh

WD="/data/data-source/bloom-boff"
NOW=`dconv now`

for i in "${WD}/download-nobackup"/*dif*; do
	bsdcat "${i}"
	rm -f -- "${i}"
done \
	| tee >(xz -c > "${WD}/tmp/raw_${NOW}.xz") \
	| "${WD}/scripts/ttlify-boff.awk" --diff \
	| tee >(gzip -c > "${WD}/tmp/ttl.d_${NOW}.gz")
