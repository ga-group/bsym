#!/usr/bin/awk -f

function ttlesc(str)
{
	gsub(/\\/, "\\\\", str);
	gsub(/"/, "\\\"", str);
	return str;
}

BEGIN {
	FS = "\t";
	OFS = " ";
	print "@prefix foaf: <http://xmlns.com/foaf/0.1/> .";
	print "@prefix figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/> .";
	print "@prefix owl: <http://www.w3.org/2002/07/owl#> .";
	print "@prefix mic: <http://fadyart.com/markets#> .";
	print "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .";
	print "@prefix gas: <http://schema.ga-group.nl/symbology#> .";
	print "@prefix gn: <http://www.geonames.org/ontology#> .";
	print "@prefix dbo: <http://dbpedia.org/ontology/> .";
	print "@prefix dc: <http://purl.org/dc/elements/1.1/> .";
	print "@prefix time: <http://www.w3.org/2006/time#> .";
	print;

	M["JANUARY"] = "01";
	M["FEBRUARY"] = "02";
	M["MARCH"] = "03";
	M["APRIL"] = "04";
	M["MAY"] = "05";
	M["JUNE"] = "06";
	M["JULY"] = "07";
	M["AUGUST"] = "08";
	M["SEPTEMBER"] = "09";
	M["OCTOBER"] = "10";
	M["NOVEMBER"] = "11";
	M["DECEMBER"] = "12";
}
(FNR > 1) {
	print "mic:" $1, "a", "figi-gii:PricingSource ;";
	print "  ", "gn:countryCode", "\"" $3 "\"", ";"
	if ($4 != $1) {
		print "  ", "dbp-ont:operatedBy", "mic:" $4, ";";
	}
	if ($9 && !($9 ~ / /) && $9 ~ /\./) {
		if (tolower(substr($9, 1, 4)) != "http") {
			$9 = "http://" $9;
		}
		print "  ", "foaf:homepage", "<" tolower($9) ">", ";";
	}
	## prepare creation date
	split($12, crea, " ");
	if (M[crea[1]]) {
		print "  ", "dc:created", "\"" crea[2] "-" M[crea[1]] "\"^^xsd:gYearMonth", ";";
	}
	print "  ", "foaf:name", "\"" ttlesc($6) "\"", ";";
	if ($8) {
		print "  ", "time:timeZone", "<http://dbpedia.org/resource/>", ";";
	}
	print "  ", "gas:symbolOf", "<http://www.iso20022.org/10383/>", ".";
}
