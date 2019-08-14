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

SELECT ?figi ?cfi ?prov WHERE {
	?figi gas:componentOf ?cfigi .
	?cfigi gas:classifiedAs ?cfi .
	## only CFIs
	?cfi gas:symbolOf <http://www.iso.org/standard/44799.html> .
	## check provenance
	OPTIONAL {
		?prov rdf:subject ?cfigi ; rdf:object ?cfi
	}
	FILTER NOT EXISTS { ?prov prov:wasInvalidatedBy ?inv }
};
