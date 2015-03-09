#!/usr/bin/awk -f

function ttlesc(str)
{
	gsub(/\\/, "\\\\", str);
	gsub(/"/, "\\\"", str);
	return str;
}

BEGIN {
	FS = OFS = "\t";

	print "@prefix foaf: <http://xmlns.com/foaf/0.1/> .";
	print "@prefix bsym: <http://bsym.bloomberg.com/sym/> .";
	print "@prefix bps: <http://bsym.bloomberg.com/pricing_source/> .";
	print "@prefix figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/> .";
	print "@prefix gas: <http://schema.ga-group.nl/symbology#> .";
	print "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .";
	print "@prefix isin: <http://www.isin.org/isin-preview/?isin=> .";
	print "@prefix skos: <http://www.w3.org/2004/02/skos/core#> .";
	print;

	mstbl["Comdty"] = "CommodityMarketSector";
	mstbl["Corp"] = "CorporateBondMarketSector";
	mstbl["Curncy"] = "CurrencyMarketSector";
	mstbl["Equity"] = "EquityMarketSector";
	mstbl["Govt"] = "GovernmentBondMarketSector";
	mstbl["Index"] = "IndexFundMarketSector";
	mstbl["M-Mkt"] = "MoneyMarketFundMarketSector";
	mstbl["Mtge"] = "MortgageMarketSector";
	mstbl["Muni"] = "MunicipalBondMarketSector";
	mstbl["Pfd"] = "PreferredStockMarketSector";
}
## we simply assume the first element is a isin
{
	if ($2 == $3) {
		print "bsym:" $2, "a", "figi-gii:CompositeGlobalIdentifier ;";
	} else {
		print "bsym:" $2, "a", "figi-gii:GlobalIdentifier ;";
		if ($3) {
			print "", "gas:componentOf", "bsym:" $3 " ;";
		}
	}
	print "", "gas:sector", "figi-gii:" mstbl[$6] " ;";
	print "", "foaf:name", "\"" ttlesc($8) "\" ;";
	if ($5) {
		print "", "gas:listedOn", "bps:" $5 " ;";
	}
	print "", "gas:listedAs", "\"" ttlesc($4) "\" ;";
	print "", "skos:broader", "isin:" $1 " ;";
	print "", "gas:symbolOf", "bsym: , <http://www.bloomberg.com/> .";

	print "isin:" $1, "a", "gas:ISIN .";
}
