#!/usr/bin/awk -f

BEGIN {
	FS = "\t";
	OFS = "\t";
	print "@prefix foaf: <http://xmlns.com/foaf/0.1/> .";
	print "@prefix bps: <http://bsym.bloomberg.com/pricing_source/> .";
	print "@prefix figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/> .";
	print "@prefix owl: <http://www.w3.org/2002/07/owl#> .";
	print "@prefix mic: <http://fadyart.com/markets#> .";
	print "@prefix skos: <http://www.w3.org/2004/02/skos/core#> .";
	print "@prefix gas: <http://schema.ga-group.nl/symbology#> .";
	print;

	mstbl["Commodity"] = "CommodityMarketSector";
	mstbl["Corporate"] = "CorporateBondMarketSector";
	mstbl["Currency"] = "CurrencyMarketSector";
	mstbl["Equity"] = "EquityMarketSector";
	mstbl["Government"] = "GovernmentBondMarketSector";
	mstbl["Index"] = "IndexFundMarketSector";
	mstbl["Mortgage"] = "MortgageMarketSector";
	mstbl["Muni"] = "MunicipalBondMarketSector";
	mstbl["Preferred"] = "PreferredStockMarketSector";
}
(FNR > 1) {
	print "bps:" $2, "a", "figi-gii:PricingSource ;";

	patsplit($1, sec, "[^, \t]+");
	for (i in sec) {
		if ((x = mstbl[sec[i]])) {
			print "", "gas:coversSector", x " ;";
		}
	}

	gsub(/"/, "\\\"", $3);
	print "", "foaf:name", "\"" $3 "\" .";
}
