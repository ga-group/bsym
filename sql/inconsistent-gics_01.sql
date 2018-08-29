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
-- This snippet detects GICS assignments in constituents of a composite
-- where the constituent is classified differently.

SELECT ?figi ?gics ?prov ?cfigi ?cgics ?cprov WHERE {
	?figi gas:componentOf ?cfigi .
	?figi gas:classifiedAs ?gics .
	?cfigi gas:classifiedAs ?cgics .
	## only GICSes
	?gics gas:symbolOf <http://www.msci.com/> .
	?cgics gas:symbolOf <http://www.msci.com/> .
	## only get that sub-industry
	FILTER EXISTS { ?gics skos:definition ?x }
	FILTER EXISTS { ?cgics skos:definition ?x }
	## only inconsistent ones
	FILTER (?gics != ?cgics)
	## make sure they are not just reclassifications
	FILTER NOT EXISTS { ?cfigi gas:classifiedAs ?gics }
	FILTER NOT EXISTS { ?figi gas:classifiedAs ?cgics }
	## check provenance
	OPTIONAL {
		?prov rdf:subject ?figi ; rdf:object ?gics
	}
	OPTIONAL {
		?cprov rdf:subject ?cfigi ; rdf:object ?cgics
	}
	FILTER NOT EXISTS { ?prov prov:wasInvalidatedBy ?inv }
	FILTER NOT EXISTS { ?cprov prov:wasInvalidatedBy ?cinv }
};
