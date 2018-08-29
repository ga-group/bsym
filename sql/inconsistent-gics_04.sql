SPARQL
DEFINE input:inference <http://schema.ga-group.nl/symbology#>
DEFINE input:same-as "yes"
PREFIX gas: <http://schema.ga-group.nl/symbology#>
PREFIX figi: <http://openfigi.com/id/>
PREFIX bps: <http://bsym.bloomberg.com/pricing_source/>
PREFIX figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX prov: <http://www.w3.org/ns/prov#>

-- GICS (or any industry classification) actually lives at the issuer level
-- however common data sources, more often than not, present industry data
-- alongside issues (shares, bonds, etc.)
-- This snippet detects GICS assignments in sibling issues of an issuer
-- where one issue is classified differently.

SELECT ?figi1 ?gics1 ?prov1 ?figi2 ?gics2 ?prov2 WHERE {
	?figi1 gas:issuedBy ?issr .
	?figi2 gas:issuedBy ?issr .
	?figi1 gas:classifiedAs ?gics1 .
	?figi2 gas:classifiedAs ?gics2 .
	## only GICSes
	?gics1 gas:symbolOf <http://www.msci.com/> .
	?gics2 gas:symbolOf <http://www.msci.com/> .
	## only get that sub-industry
	FILTER EXISTS { ?gics1 skos:definition ?x }
	FILTER EXISTS { ?gics2 skos:definition ?x }
	## only inconsistent ones
	FILTER (?gics1 != ?gics2)
	## make sure they are not just reclassifications
	FILTER NOT EXISTS { ?figi2 gas:classifiedAs ?gics1 }
	FILTER NOT EXISTS { ?figi1 gas:classifiedAs ?gics2 }
	## check provenance
	OPTIONAL {
		?prov1 rdf:subject ?figi1 ; rdf:object ?gics1
	}
	OPTIONAL {
		?prov2 rdf:subject ?figi2 ; rdf:object ?gics2
	}
	FILTER NOT EXISTS { ?prov1 prov:wasInvalidatedBy ?inv1 }
	FILTER NOT EXISTS { ?prov2 prov:wasInvalidatedBy ?inv2 }
};
