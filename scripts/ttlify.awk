#!/usr/bin/awk -f

function ttlesc(str)
{
	gsub(/\\/, "\\\\", str);
	gsub(/"/, "\\\"", str);
	return str;
}

BEGIN {
	FS = "|";
	OFS = "\t";

	for (i = 0; i < ARGC; i++) {
		if (ARGV[i] == "--help") {
			print "Usage: ttlify-new.awk [--since DATE] [--till DATE] FILE...";
			exit(0);
		} else if (ARGV[i] == "--since") {
			SINCE = ARGV[i + 1];
			delete ARGV[i];
			delete ARGV[i + 1];
		} else if (ARGV[i] == "--till") {
			TILL = ARGV[i + 1];
			delete ARGV[i];
			delete ARGV[i + 1];
		}
	}

	print "@prefix foaf: <http://xmlns.com/foaf/0.1/> .";
	print "@prefix bsym: <http://bsym.bloomberg.com/sym/> .";
	print "@prefix bps: <http://bsym.bloomberg.com/pricing_source/> .";
	print "@prefix figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/> .";
	print "@prefix gas: <http://schema.ga-group.nl/symbology#> .";
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
(FNR > 1) {
	if (!$8) {
		next;
	} else if (TILL) {
		s = ($8 == $9) ? $9 : $8;
		print "bsym:" s, "gas:listedTill", "\"" TILL "\"^^xsd:date .";
		next;
	}
	if ($8 == $9) {
		print "bsym:" $9, "a", "figi-gii:CompositeGlobalIdentifier ;";
	} else {
		print "bsym:" $8, "a", "figi-gii:GlobalIdentifier ;";
		if ($9) {
			print "", "gas:componentOf", "bsym:" $9 " ;";
		}
	}
	print "", "gas:sector", "figi-gii:" mstbl[$7] " ;";
	print "", "foaf:name", "\"" ttlesc($1) "\" ;";
	if ($3) {
		print "", "gas:listedOn", "bps:" $3 " ;";
	}
	print "", "gas:listedAs", "\"" ttlesc($2) "\" ;";
	if (SINCE) {
		print "", "gas:listedSince", "\"" SINCE "\"^^xsd:date ;"
	}
	print "", "gas:symbolOf", "bsym: , <http://www.bloomberg.com/> .";
}
