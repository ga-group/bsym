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
-- This snippet takes GICS assignments from issues to issuer along with
-- provenance data for insertion and deletion

SELECT ?figi ?gics ?prov ?issr WHERE {
	?figi gas:issuedBy ?issr .
	?figi gas:classifiedAs ?gics .
	## only GICSes
	?gics gas:symbolOf <http://www.msci.com/> .
	## only get that sub-industry
	FILTER EXISTS { ?gics skos:definition ?x }
	## stay within symbologies
	?figi gas:symbolOf ?symb .
	?issr gas:symbolOf ?symb .
	## check provenance
	OPTIONAL {
		?prov rdf:subject ?figi ; rdf:object ?gics
	}
	FILTER NOT EXISTS { ?prov prov:wasInvalidatedBy ?inv }
};
