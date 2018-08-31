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

-- GICS (or any industry classification) actually lives at the issuer level
-- however common data sources, more often than not, present industry data
-- alongside issues (shares, bonds, etc.)
-- This snippet detects GICS assignments in issues of an issuer
-- where the issue is classified differently.

SELECT ?figi ?gics ?prov ?issr ?igics ?iprov WHERE {
	?figi gas:componentOf*/gas:issuedBy ?issr .
	?figi gas:componentOf*/gas:classifiedAs ?gics .
	?issr gas:classifiedAs ?igics .
	## only GICSes
	?gics gas:symbolOf <http://www.msci.com/> .
	?igics gas:symbolOf <http://www.msci.com/> .
	## only get that sub-industry
	FILTER EXISTS { ?gics skos:definition ?x }
	FILTER EXISTS { ?igics skos:definition ?x }
	## only inconsistent ones
	FILTER (?gics != ?igics)
	## make sure they are not just reclassifications
	FILTER NOT EXISTS { ?issr gas:classifiedAs ?gics }
	FILTER NOT EXISTS { ?figi gas:classifiedAs ?igics }
	## check provenance
	OPTIONAL {
		?prov rdf:subject ?figi ; rdf:object ?gics
	}
	OPTIONAL {
		?iprov rdf:subject ?issr ; rdf:object ?igics
	}
	FILTER NOT EXISTS { ?prov prov:wasInvalidatedBy ?inv }
	FILTER NOT EXISTS { ?iprov prov:wasInvalidatedBy ?iinv }
};
