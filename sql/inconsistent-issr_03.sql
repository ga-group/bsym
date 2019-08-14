SPARQL
DEFINE input:inference <http://schema.ga-group.nl/symbology#>
PREFIX gas: <http://schema.ga-group.nl/symbology#>
PREFIX figi: <http://openfigi.com/id/>
PREFIX bps: <http://bsym.bloomberg.com/pricing_source/>
PREFIX figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX prov: <http://www.w3.org/ns/prov#>

-- This snippet detects issues with multiple issuers from the same symbology.

SELECT ?figi ?issr1 ?issr2 WHERE {
	?figi gas:issuedBy ?issr1 .
	?figi gas:issuedBy ?issr2 .
	## only inconsistent ones
	FILTER (?issr1 != ?issr2)
	## stick with the symbology
	?issr1 gas:symbolOf ?symb .
	?issr2 gas:symbolOf ?symb .
};
