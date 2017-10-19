#!/usr/bin/awk -f

BEGIN {
	FS = "\t";
	OFS = "  ";
}
($1 > " " && $2) {
	print "gics:" $1, "a", "owl:Class", ".";
	print "gics:" $1, "rdfs:label" lang, "\"" $2 "\"" lang, ".";
	print "gics:" $1, "foaf:name" lang, "\"" $2 "\"" lang, ".";
	print "gics:" $1, "rdfs:subClassOf", "gas:Classification", ".";
	print "gics:" $1, "gas:symbolOf", "<http://www.msci.com/>", ".";
	l1 = $1
}
($3 > " " && $4) {
	print "gics:" $3, "a", "owl:Class", ".";
	print "gics:" $3, "rdfs:label" lang, "\"" $4 "\"" lang, ".";
	print "gics:" $3, "foaf:name" lang, "\"" $4 "\"" lang, ".";
	print "gics:" $3, "rdfs:subClassOf", "gics:" l1, ".";
	print "gics:" $3, "gas:symbolOf", "<http://www.msci.com/>", ".";
	l3 = $3
}
($5 > " " && $6) {
	print "gics:" $5, "a", "owl:Class", ".";
	print "gics:" $5, "rdfs:label" lang, "\"" $6 "\"" lang, ".";
	print "gics:" $5, "foaf:name" lang, "\"" $6 "\"" lang, ".";
	print "gics:" $5, "rdfs:subClassOf", "gics:" l3, ".";
	print "gics:" $5, "gas:symbolOf", "<http://www.msci.com/>", ".";
	l5 = $5
}
($7 > " " && $8) {
	print "gics:" $7, "a", "owl:Class", ".";
	print "gics:" $7, "rdfs:label" lang, "\"" $8 "\"" lang, ".";
	print "gics:" $7, "foaf:name" lang, "\"" $8 "\"" lang, ".";
	print "gics:" $7, "rdfs:subClassOf", "gics:" l5, ".";
	print "gics:" $7, "gas:symbolOf", "<http://www.msci.com/>", ".";
	l7 = $7
}
($7 <= " " && l7 && $8) {
	print "gics:" l7, "skos:definition" lang, "\"\"\"" $8 "\"\"\"" lang, ".";
}
