#!/usr/bin/awk -f

function mstar_esc(str)
{
	gsub(/\//, "\\.", str);
	return str;
}

BEGIN {
	FS = "\t";
	OFS = "\t";
	print "@prefix foaf: <http://xmlns.com/foaf/0.1/> .";
	print "@prefix bsym: <http://bsym.bloomberg.com/sym/> .";
	print "@prefix bps: <http://bsym.bloomberg.com/pricing_source/> .";
	print "@prefix figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/> .";
	print "@prefix gas: <http://schema.ga-group.nl/symbology#> .";
	print "@prefix mic: <http://fadyart.com/markets#> .";
	print "@prefix skos: <http://www.w3.org/2004/02/skos/core#> .";
	print "@prefix mstar: <http://financials.morningstar.com/company-profile/c.action?t=> ."
	print;
}
{
	sub(/_/, ":", $1);
	split($1, mic, ":");

	mstar_sym = mstar_esc($1);
	print "mstar:" mstar_sym, "gas:symbolOf", "<http://www.morningstar.com/> .";
	print "bsym:" $2, "a", "figi-gii:GlobalIdentifier ;";
	print "", "gas:listedOn", "mic:" mic[1] " ;";
	print "", "skos:related", "mstar:" mstar_sym " .";
}
