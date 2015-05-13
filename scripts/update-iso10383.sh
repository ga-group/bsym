#!/bin/zsh

REPORTTIME=-1

URL="http://www.iso15022.org/MIC/ISO10383_MIC.xls"
SCRDIR="`dirname "${0}"`"

curl -q -s -o "ISO10383_MIC.xls" "${URL}"
xls2txt -n2 "ISO10383_MIC.xls" \
	| "${SCRDIR}/ttlify-iso10383.awk" \
	> iso10383.ttl

## clean up
rm -f "ISO10383_MIC.xls"
