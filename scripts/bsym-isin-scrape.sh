#!/bin/zsh

REPORTTIME=-1

case "${1}" in
("--help")
	cat <<EOF
bsym-isin-snarf.sh [--ttl] ISIN...
EOF
	exit 0
	;;
("--ttl")
	ttl=true
	shift
	;;
(*)
	;;
esac

get_sess()
{
## get session id

	cnt=0
	curl -qgsf 'http://bsym.bloomberg.com/sym/dwr/call/plaincall/__System.pageLoaded.dwr' -d '
callCount=1
windowName=
c0-scriptName=__System
c0-methodName=pageLoaded
c0-id=0
batchId=$((cnt++))
page=%2Fsym%2F
httpSessionId=
scriptSessionId=
' \
	| grep -F "ScriptSession" \
	| cut -d'"' -f2
}

get1()
{
	local sym="${1}"

	if test "${ttl}" = "true"; then
		cat <<EOF
<http://www.isin.org/isin-preview/?isin=${sym}> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/ShareClassGlobalIdentifier> .
<http://www.isin.org/isin-preview/?isin=${sym}> <http://schema.ga-group.nl/symbology#isin> "${sym}" .
EOF
	fi
	curl -qgsf 'http://bsym.bloomberg.com/sym/dwr/call/plaincall/searchMgr.search.dwr' --compressed -d "callCount=1
windowName=
c0-scriptName=searchMgr
c0-methodName=search
c0-id=0
c0-e1=string:${sym}
c0-e2=string:
c0-e3=number:100
c0-e4=number:0
c0-e5=boolean:true
c0-param0=Object_SearchCriteria:{search:reference:c0-e1, filter:reference:c0-e2, limit:reference:c0-e3, start:reference:c0-e4, allSources:reference:c0-e5}
batchId=$((cnt++))
page=%2Fsym%2F
httpSessionId=
scriptSessionId=${SESSID}
" \
	| sed 's@^[^{]*@@; s@[^}]*$@@; /^$/d' \
	| sed 's@\([[:alnum:]]*\):@"\1":@g' \
	| if test "${ttl}" = "true"; then
		jq -r '.data[] | "<http://bsym.bloomberg.com/sym/" +.ID135+"> <http://www.w3.org/2004/02/skos/core#broader> <http://www.isin.org/isin-preview/?isin='${sym}'> ."'
	else
		jq -r '.data[] | "'${sym}'"+"\t"+.ID135+"\t"+.ID145+"\t"+.DY003+"\t"+.DX282+"\t"+.DS122+"\t"+.DS213+"\t"+.DS002'
	fi \
	| uniq
}

SESSID=`get_sess`

if test $# -eq 0; then
	while read i; do
		get1 "${i}"
	done
else
	for i; do
		get1 "${i}"
	done
fi
