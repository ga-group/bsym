#!/usr/bin/awk -f

BEGIN {
	FS = "\t";
	OFS = "  ";
}
($1 > " " && $2) {
	print "gics:" $1, "a", "gas:Classification", ".";
	print "gics:" $1, "foaf:name" lang, "\"" $2 "\"" lang, ".";
	print "gics:" $1, "gas:symbolOf", "<http://www.msci.com/>", ".";
}
($3 > " " && $4) {
	print "gics:" $3, "a", "gas:Classification", ".";
	print "gics:" $3, "foaf:name" lang, "\"" $4 "\"" lang, ".";
	print "gics:" $3, "gas:symbolOf", "<http://www.msci.com/>", ".";
}
($5 > " " && $6) {
	print "gics:" $5, "a", "gas:Classification", ".";
	print "gics:" $5, "foaf:name" lang, "\"" $6 "\"" lang, ".";
	print "gics:" $5, "gas:symbolOf", "<http://www.msci.com/>", ".";
}
($7 > " " && $8) {
	print "gics:" $7, "a", "gas:Classification", ".";
	print "gics:" $7, "foaf:name" lang, "\"" $8 "\"" lang, ".";
	print "gics:" $7, "gas:symbolOf", "<http://www.msci.com/>", ".";
	l7 = $7
}
($7 <= " " && l7 && $8) {
	print "gics:" l7, "skos:definition" lang, "\"\"\"" $8 "\"\"\"" lang, ".";
}
